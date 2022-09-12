defmodule Bonfire.Recyclapp.CreateObservationForm do
  import Ecto.Changeset
  import Untangle
  alias ValueFlows.Observe.Observations
  alias Bonfire.Common.Utils

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
    |> validate_required([
      :has_feature_of_interest,
      :observed_property,
      :has_result
    ])
  end

  def send(
        changeset,
        %{
          "has_feature_of_interest" => has_feature_of_interest,
          "observed_property" => observed_property,
          "result_phenomenon" => result_phenomenon
        } = params,
        socket
      )
      when is_binary(result_phenomenon) do
    user = Utils.current_user(socket)
    provider = user.id
    debug(params)
    # debug(has_result)
    # {float, ""} = Float.parse(has_result)
    # has_result = %{
    #   has_numerical_value: float,
    #   has_unit: unit
    # }
    attrs = %{
      provider: provider,
      has_feature_of_interest: has_feature_of_interest,
      observed_property: observed_property,
      result_phenomenon: result_phenomenon
    }

    case apply_action(changeset, :insert) do
      {:ok, _} ->
        with {:ok, observation} <- Observations.create(user, attrs) do
          {:ok, observation}
        else
          _e ->
            {nil, "Incorrect details for observation. Please try again..."}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def send(changeset, _, _) do
    {nil, "Incorrect details for observation. Please try again..."}
  end
end
