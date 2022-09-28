defmodule Bonfire.Recyclapp.CreateEventForm do
  import Ecto.Changeset
  import Bonfire.Recyclapp.Integration
  alias ValueFlows.EconomicEvent.EconomicEvents
  alias ValueFlows.EconomicEvent.EconomicEvent
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications
  alias Bonfire.Common.Utils

  defstruct [:label, :symbol]

  @types %{
    resource: :string,
    note: :string,
    quantity: :float
  }

  def changeset(attrs \\ %{}) do
    {%__MODULE__{}, @types}
    |> cast(attrs, [:note, :resource, :quantity])
    |> validate_required([:resource, :quantity])
  end

  def send(
        changeset,
        %{"resource" => resource, "note" => note, "quantity" => quantity} = _params,
        socket
      ) do
    user = Utils.current_user_required(socket)

    {:ok, resource_spec} =
      ResourceSpecifications.one([
        :default,
        user: user,
        id: resource
      ])

    float = with {float, ""} <- Float.parse(quantity), do: float

    event_attrs = %{
      note: note,
      provider: user.id,
      receiver: user.id,
      action: "transfer",
      resource_conforms_to: resource_spec,
      resource_quantity: %{
        unit: resource_spec.default_unit_of_effort,
        has_numerical_value: float
      },
      effort_quantity: %{
        unit: resource_spec.default_unit_of_effort,
        has_numerical_value: float
      }
    }

    d = DateTime.utc_now()

    new_inventoried_resource = %{
      name: resource_spec.name <> "-" <> DateTime.to_string(d)
    }

    case apply_action(changeset, :insert) do
      {:ok, _} ->
        EconomicEvents.create(user, event_attrs, %{
          new_inventoried_resource: new_inventoried_resource
        })

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
