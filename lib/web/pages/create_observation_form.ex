defmodule  Bonfire.UI.Contribution.CreateObservationForm do
  import Ecto.Changeset
  alias ValueFlows.Observe.Observations

  defstruct [:name, :note]

  @types %{
    has_feature_of_interest: :string,
    observed_property: :string,
    has_result: :string,
    unit: :string
  }

  def changeset(attrs \\ %{}) do
    {%__MODULE__{}, @types}
    |> cast(attrs, [:has_feature_of_interest, :observed_property, :has_result])
    |> validate_required([:has_feature_of_interest, :observed_property, :has_result])
  end

  def send(changeset, %{"has_feature_of_interest" => has_feature_of_interest, "observed_property" => observed_property} = params, socket) do
    user = Map.get(socket.assigns, :current_user)
    provider = user.id
    IO.inspect(params)
    # IO.inspect(has_result)
    # {float, ""} = Float.parse(has_result)
    # has_result = %{
    #   has_numerical_value: float,
    #   has_unit: unit
    # }
    attrs = %{
      provider: provider,
      has_feature_of_interest: has_feature_of_interest,
      observed_property: observed_property,
      result_phenomenon: params["result_phenomenon"]
    }
    case apply_action(changeset, :insert) do
      {:ok, _} ->

        with {:ok, observation} <- Observations.create(user, attrs) do
          {:ok, observation}
        else _e ->
          {nil, "Incorrect details. Please try again..."}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
