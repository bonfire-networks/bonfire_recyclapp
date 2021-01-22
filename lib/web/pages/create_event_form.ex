defmodule  Bonfire.UI.Contribution.CreateEventForm do
  import Ecto.Changeset
  alias ValueFlows.EconomicEvent.EconomicEvents
  alias ValueFlows.EconomicEvent.EconomicEvent
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications

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

  def send(changeset, %{"resource" => resource, "note" => note, "quantity" => quantity} = _params, socket) do
    user = Map.get(socket.assigns, :current_user)
    {:ok, resource_spec} =  ResourceSpecifications.one([
      :default,
      user: user,
      id: resource
    ])
    {float, ""} = Float.parse(quantity) 
    event_attrs = %{
      note: note,
      provider: user.id,
      receiver: user.id,
      action: "transfer",
      resource_quantity: %{
        unit: resource_spec.default_unit_of_effort,
        has_numerical_value: float
      }
    }
    d = DateTime.utc_now
    
    new_inventoried_resource = %{
      name: resource_spec.name <> "-" <> DateTime.to_string(d),

    }

    case apply_action(changeset, :insert) do
      {:ok, _} ->
        res = EconomicEvents.create(user, event_attrs, %{
          new_inventoried_resource: new_inventoried_resource
        })

        if(is_nil(res)) do
          {nil, "Incorrect details. Please try again..."}
        else
          {:ok, res}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end