defmodule Bonfire.UI.Contribution.ContributionDashboardLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Contribution.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}

  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  alias Bonfire.UI.Contribution.CreateEventForm
  alias Bonfire.UI.Contribution.CreateObservationForm

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
    queries = queries(socket)
    changeset = CreateEventForm.changeset()
    {:ok, socket
    |> assign(
      page_title: "Home",
      all_resources: queries.resource_specifications,
      all_events: queries.economic_events_pages.edges,
      all_units: queries.units_pages.edges,
      all_observable_properties: Map.get(queries.observable_properties_pages, :edges, []),
      changeset: changeset,
      selected_property: hd(Map.get(queries.observable_properties_pages, :edges, []))
    )}
  end



  def handle_event("validate", %{"create_event_form" => params}, socket) do
    IO.inspect(validate: params)

    changeset = CreateEventForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)

    socket = if params["property"] && params["property"] != Map.get(socket.assigns.selected_property, :id) do
      # IO.inspect(socket.assigns.all_observable_properties)
      property = Enum.find(socket.assigns.all_observable_properties, fn map -> map.id == params["property"] end)
      IO.inspect(property)
      assign(socket, selected_property: property)
    else
      socket
    end

    {:noreply, socket}
  end

  def handle_event("submit",  %{"create_event_form" => params}, socket) do
    IO.inspect(submit: params)
    changeset = CreateEventForm.changeset(params)
     # has_result = %{
    #   unit: resource_spec.default_unit_of_effort,
    #   has_numerical_value: high
    # }
    # CreateObservationForm.send(changeset, %{has_feature_of_interest: resource.id, observed_property: property, }, socket)
    # def send(changeset, %{"has_feature_of_interest" => has_feature_of_interest, "observed_property" => observed_property, "has_result" => has_result, "unit" => unit} = _params, socket) do

   case CreateEventForm.send(changeset, params, socket) do
      {:ok, event, resource} ->
        with {:ok, high_obs} <- CreateObservationForm.send(changeset, %{
          "has_feature_of_interest" => resource.id,
          "observed_property" => params["property"],
          "result_phenomenon" => params["phenomenon"]
        }, socket)
        #      {:ok, medium_obs} <- CreateObservationForm.send(changeset,  %{
        #       "has_feature_of_interest" => resource.id,
        #       "observed_property" => params["property"],
        #       "has_result" => params["medium"],
        #       "unit" => params["unit_medium"]

        #     }, socket),
        #      {:ok, low_obs} <- CreateObservationForm.send(changeset, %{
        #       "has_feature_of_interest" => resource.id,
        #       "observed_property" => params["property"],
        #       "has_result" => params["low"],
        #       "unit" => params["unit_low"]
        #     }, socket)
        do
          {:noreply,
          socket
          |> put_flash(:info, "Donation successfully recorded!")
          |> assign(all_events: [event] ++ socket.assigns.all_events)
          }
        end

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        {:noreply,
        socket
        |> assign(changeset: CreateEventForm.changeset(%{}))
        |> put_flash(:error, message)}
    end
  end



  @graphql """
  {
    resource_specifications {
      id
      note
      name
      default_unit_of_effort {
        label
        id
      }
    }
    units_pages {
      edges {
        id
        label
        symbol
      }
    }
    observable_properties_pages(limit: 10) {
      edges {
        id
        label
        has_choices {
          id
          label
          formula_quantifier
        }
      }
    }
    economic_events_pages(limit: 10) {
      edges {
        id
        note
        action {
          id
        }
        receiver {
          name
        }
        resource_inventoried_as {
          name
        }
        resource_quantity {
          has_unit {
            label
          }
          has_numerical_value
        }
      }
    }
  }
  """
  def queries(params \\ %{}, socket), do: liveql(socket, :queries, params)

  def spec_unit(spec) do
    unit = e(spec, :default_unit_of_effort, :label, nil)
    if unit do
      " (#{unit})"
    else
      ""
    end
  end
end
