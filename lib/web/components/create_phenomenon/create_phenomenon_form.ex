defmodule Bonfire.Recyclapp.CreatePhenomenonForm do
  import Ecto.Changeset
  alias ValueFlows.Observe.ObservablePhenomenons
  alias Bonfire.Common.Utils

  defstruct [:name, :note]

  @types %{
    property: :string,
    name: :string,
    formula: :float,
    note: :string
  }

  def changeset(attrs \\ %{}) do
    {%__MODULE__{}, @types}
    |> cast(attrs, [:name, :property, :formula])
    |> validate_required([:name, :property, :formula])
    |> validate_length(:name, min: 2, max: 100)
  end

  def send(
        changeset,
        %{
          "name" => name,
          "formula" => formula,
          "property" => property,
          "note" => note
        } = _params,
        socket
      ) do
    user = Utils.current_user(socket)
    {float, ""} = Float.parse(formula)

    case apply_action(changeset, :insert) do
      {:ok, _} ->
        with {:ok, phenomenon} <-
               ObservablePhenomenons.create(user, property, %{
                 name: name,
                 note: note,
                 formula_quantifier: float
               }) do
          {:ok, phenomenon}
        else
          _e ->
            {nil, "Incorrect details. Please try again..."}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
