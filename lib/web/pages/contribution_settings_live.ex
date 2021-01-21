defmodule Bonfire.UI.Contribution.ContributionSettingsLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Contribution.LayoutView, "live.html"}]}
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]
  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.UI.Contribution.CreateUnitForm

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(params, session, socket) do
    units = all_units(socket)
    changeset = CreateUnitForm.changeset()
    IO.inspect(units)
    {:ok, socket
    |> assign(
      page_title: "Settings",
      changeset: changeset,
      all_units: units
    )}
  end

  def handle_event("validate", %{"login_form" => params}, socket) do
    changeset = CreateUnitForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit", params, socket) do
    changeset = CreateUnitForm.changeset(params)

    case CreateUnitForm.send(changeset, params, socket) do
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Logged in!")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {nil, message} ->
        {:noreply,
         socket
         |> assign(changeset: CreateUnitForm.changeset(%{}))
         |> put_flash(:error, message)}
    end
  end


  @graphql """
    {
      unitsPages {
        edges {
          id
          label
          symbol
        }
      }
    }
  """


  def unitsPages(params \\ %{}, socket), do: liveql(socket, :unitsPages, params)
  def all_units(socket), do: unitsPages(socket)


end
