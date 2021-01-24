defmodule Bonfire.UI.Contribution.ContributionSettingsLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Contribution.LayoutView, "live.html"}]}
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.UI.Contribution.CreateUnitForm
  alias Bonfire.UI.Contribution.CreateResourceSpecForm
  alias Bonfire.UI.Contribution.CreateObservatablePropertyForm
  alias Bonfire.UI.Contribution.CreatePhenomenonForm


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
    settings_queries = settings_queries(socket)
    # IO.inspect(settings_queries)
    changeset = CreateUnitForm.changeset()
    changeset_resource = CreateResourceSpecForm.changeset()
    changeset_property = CreateObservatablePropertyForm.changeset()
    changeset_phenomenon = CreatePhenomenonForm.changeset()
    {:ok, socket
    |> assign(
      page_title: "Settings",
      changeset: changeset,
      changeset_resource: changeset_resource,
      changeset_property: changeset_property,
      changeset_phenomenon: changeset_phenomenon,
      all_units: settings_queries.units_pages.edges,
      all_res: settings_queries.resource_specifications_pages.edges,
      all_properties: settings_queries.observable_properties_pages.edges,
      all_phenomenon: settings_queries.observable_phenomenon_pages.edges
    )}
  end


  def handle_event("validate_property", %{"create_observatable_property_form" => params}, socket) do
    changeset = CreateObservatablePropertyForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset_property: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_property",  %{"create_observatable_property_form" => params}, socket) do
    changeset = CreateObservatablePropertyForm.changeset(params)

    case CreateObservatablePropertyForm.send(changeset, params, socket) do
      {:ok, property} ->
        {:noreply,
         socket
         |> put_flash(:info, "Property successfully created!")
         |> assign(all_properties: [property] ++ socket.assigns.all_properties)
       }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset_property: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
         |> assign(changeset_property: CreateObservatablePropertyForm.changeset(%{}))
    end
  end

  def handle_event("validate_phenomenon", %{"create_phenomenon_form" => params}, socket) do
    changeset = CreatePhenomenonForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset_phenomenon: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_phenomenon",  %{"create_phenomenon_form" => params}, socket) do
    changeset = CreatePhenomenonForm.changeset(params)

    case CreatePhenomenonForm.send(changeset, params, socket) do
      {:ok, phenomenon} ->
        {:noreply,
         socket
         |> put_flash(:info, "phenomenon successfully created!")
         |> assign(all_phenomenon: [phenomenon] ++ socket.assigns.all_phenomenon)
       
       }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset_property: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
         |> assign(changeset_property: CreatePhenomenonForm.changeset(%{}))
    end
  end


 
  def handle_event("validate_unit", %{"create_unit_form" => params}, socket) do
    changeset = CreateUnitForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_unit",  %{"create_unit_form" => params}, socket) do
    changeset = CreateUnitForm.changeset(params)

    case CreateUnitForm.send(changeset, params, socket) do
      {:ok, unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit successfully created!")
         |> assign(all_units: [unit] ++ socket.assigns.all_units)
       }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
         |> assign(changeset: CreateUnitForm.changeset(%{}))
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
      {:ok, resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource specification correctly created!")
         |> assign(all_res: [resource] ++ socket.assigns.all_res)
        }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> assign(changeset: CreateResourceSpecForm.changeset(%{}))
         |> put_flash(:error, message)}
    end
  end


  @graphql """
    {
      units_pages {
        edges {
          id
          label
          symbol
        }
      }
      observable_properties_pages {
        edges {
          id
          note
          label
        }
      }
      observable_phenomenon_pages {
        edges {
          label
          note
          formula_quantifier
          choice_of {
            label
          }
        }
      }
      resource_specifications_pages {
        edges {
          id
          note
          name
          default_unit_of_effort {
            label
            id
          }
        }
      }
    }
  """


  def settings_queries(params \\ %{}, socket), do: liveql(socket, :settings_queries, params)


end
