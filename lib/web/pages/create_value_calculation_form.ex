defmodule  Bonfire.UI.Contribution.CreateValueCalculationForm do
  import Ecto.Changeset
  alias ValueFlows.ValueCalculation.ValueCalculations

  defstruct [:name, :note]

  @types %{
    name: :string,
    note: :string,
    resource_conforms_to: :string,
    action: :string,
    value_action: :string,
    formula: :string,
    value_unit: :string,
    value_resource_conforms_to: :string
  }

  def changeset(attrs \\ %{}) do
    {%__MODULE__{}, @types}
    |> cast(attrs, [:name, :note, :resource_conforms_to, :action, :value_action, :formula, :value_unit, :value_resource_conforms_to])
    |> validate_required([:name, :formula, :value_unit, :action, :value_action])
  end

  def send(changeset, %{
    "name" => name, 
    "formula" => formula, 
    "resource_conforms_to" => resource_conforms_to, 
    "note" => note,
    "action" => action,
    "value_action" => value_action,
    "value_unit" => value_unit,
    "value_resource_conforms_to" => value_resource_conforms_to
    } = _params, socket) do
    user = Map.get(socket.assigns, :current_user)
    value_attrs = %{
      name: name, 
      formula: formula, 
      resource_conforms_to: resource_conforms_to, 
      note: note,
      action: action,
      value_action: value_action,
      value_unit: value_unit,
      value_resource_conforms_to: value_resource_conforms_to
    }
    case apply_action(changeset, :insert) do
      {:ok, _} ->
        with {:ok, value_calc} <- ValueCalculations.create(user, value_attrs) do
          {:ok, value_calc}
        else _e ->
          {nil, "Incorrect details. Please try again..."}
        end
        
        {:error, changeset} ->
        {:error, changeset}
    end
  end
end
