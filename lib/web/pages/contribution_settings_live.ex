defmodule Bonfire.UI.Contribution.ContributionSettingsLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Contribution.LayoutView, "live.html"}]}
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.UI.Contribution.CreateUnitForm
  alias Bonfire.UI.Contribution.CreateResourceSpecForm
  alias Bonfire.UI.Contribution.CreateObservablePropertyForm
  alias Bonfire.UI.Contribution.CreatePhenomenonForm
  alias Bonfire.UI.Contribution.CreateValueCalculationForm

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
    changeset_property = CreateObservablePropertyForm.changeset()
    changeset_phenomenon = CreatePhenomenonForm.changeset()
    changeset_value_calculation = CreateValueCalculationForm.changeset()
    {:ok, socket
    |> assign(
      page_title: "Settings",
      changeset: changeset,
      changeset_resource: changeset_resource,
      changeset_property: changeset_property,
      changeset_phenomenon: changeset_phenomenon,
      changeset_value_calculation: changeset_value_calculation,
      all_units: settings_queries.units_pages.edges,
      all_resources: settings_queries.resource_specifications_pages.edges,
      all_properties: settings_queries.observable_properties_pages.edges,
      all_phenomenon: settings_queries.observable_phenomenon_pages.edges,
      actions: settings_queries.actions
    )}
  end


  def handle_event("validate_value_calculation", %{"create_value_calculation_form" => params}, socket) do
    IO.inspect(params)
    changeset = CreateValueCalculationForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset_value_calculation: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_value_calculation",  %{"create_value_calculation_form" => params}, socket) do
    changeset = CreateValueCalculationForm.changeset(params)
    case CreateValueCalculationForm.send(changeset, params, socket) do
      {:ok, property} ->
        {:noreply, 
          socket
          |> put_flash(:info, "Value calculation successfully created!")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset_value_calculation: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
         |> assign(changeset_value_calculation: CreateValueCalculationForm.changeset(%{}))
    end
  end

  def handle_event("validate_property", %{"create_observable_property_form" => params}, socket) do
    changeset = CreateObservablePropertyForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset_property: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_property",  %{"create_observable_property_form" => params}, socket) do
    changeset = CreateObservablePropertyForm.changeset(params)

    case CreateObservablePropertyForm.send(changeset, params, socket) do
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
         |> assign(changeset_property: CreateObservablePropertyForm.changeset(%{}))
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
         |> put_flash(:info, "Phenomenon successfully created!")
         |> assign(all_phenomenon: [phenomenon] ++ socket.assigns.all_phenomenon)
       }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset_property: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)
         |> assign(changeset_phenomenon: CreatePhenomenonForm.changeset(%{}))
        }
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
         |> assign(all_resources: [resource] ++ socket.assigns.all_resources)
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
      actions {
        id
        label
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
