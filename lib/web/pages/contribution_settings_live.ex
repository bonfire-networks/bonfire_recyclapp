defmodule Bonfire.UI.Contribution.ContributionSettingsLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Contribution.LayoutView, "live.html"}]}
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]
  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.UI.Contribution.CreateUnitForm
  alias Bonfire.UI.Contribution.CreateResourceSpecForm

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
    changeset_resource = CreateResourceSpecForm.changeset()
    {:ok, socket
    |> assign(
      page_title: "Settings",
      changeset: changeset,
      changeset_resource: changeset_resource,
      all_units: units.unitsPages.edges,
      all_res: units.resource_specifications
    )}
  end

 
  def handle_event("validate", %{"create_unit_form" => params}, socket) do
    changeset = CreateUnitForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit",  %{"create_unit_form" => params}, socket) do
    changeset = CreateUnitForm.changeset(params)

    case CreateUnitForm.send(changeset, params, socket) do
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit successfully created!")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {nil, message} ->
        {:noreply,
         socket
         |> assign(changeset: CreateUnitForm.changeset(%{}))
         |> put_flash(:error, message)}
    end
  end

  def handle_event("validate_resource", %{"create_resource_spec_form" => params}, socket) do
    changeset = CreateResourceSpecForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset_resource: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_resource",  %{"create_resource_spec_form" => params}, socket) do
    changeset = CreateResourceSpecForm.changeset(params)

    case CreateResourceSpecForm.send(changeset, params, socket) do
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource specification correctly created!")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {nil, message} ->
        {:noreply,
         socket
         |> assign(changeset: CreateResourceSpecForm.changeset(%{}))
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
      resource_specifications {
        id
        note
        name
        default_unit_of_effort {
          label
          id
        }
      }
    }
  """


  def unitsPages(params \\ %{}, socket), do: liveql(socket, :unitsPages, params)
  def all_units(socket), do: unitsPages(socket)


end
