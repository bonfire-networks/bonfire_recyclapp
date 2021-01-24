defmodule  Bonfire.UI.Contribution.CreateResourceSpecForm do
  import Ecto.Changeset
  import Bonfire.UI.Contribution.Integration
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecification

  defstruct [:label, :symbol]

  @types %{
    name: :string,
    note: :string,
    unit: :string
  }

  def changeset(attrs \\ %{}) do
    {%__MODULE__{}, @types}
    |> cast(attrs, [:name, :note, :unit])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
  end

  def send(changeset, %{"name" => name, "note" => note, "unit" => unit} = _params, socket) do
    user = Map.get(socket.assigns, :current_user)
    case apply_action(changeset, :insert) do
      {:ok, _} ->

        with {:ok, res} <- ResourceSpecifications.create(user, %{name: name, note: note, default_unit_of_effort: unit, is_public: true}) do
          {:ok, repo.preload(res, :default_unit_of_effort)}
        else _e ->
          {nil, "Incorrect details. Please try again..."}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end