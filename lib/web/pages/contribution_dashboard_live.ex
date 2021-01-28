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
    events = e(queries, :economic_events_pages, :edges, [])
    {:ok, socket
    |> assign(
      page_title: "Home",
      observed: [],
      all_resources: e(queries, :resource_specifications_pages, :edges, []),
      all_events: Enum.filter(events, fn ev -> ev.triggered_by != nil end),
      all_observable_properties: e(queries, :observable_properties_pages, :edges, []),
      changeset: changeset,
      selected_property: List.first(e(queries, :observable_properties_pages, :edges, []))
    )}
  end


  def handle_event("add_observation", %{"id" => id}, socket) do
    cond do
      Enum.member?(socket.assigns.observed, id) == false ->
        socket = assign(socket, observed: [id] ++ socket.assigns.observed)
        {:noreply, socket}
      Enum.member?(socket.assigns.observed, id) == true ->
        socket = assign(socket, observed: List.delete(socket.assigns.observed, id))
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"create_event_form" => params}, socket) do
    IO.inspect(validate: params)

    changeset = CreateEventForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
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
    {:ok, %{economic_event: event, reciprocal_events: reciprocals, economic_resource: resource}} ->
      IO.inspect(reciprocals)
        with {:ok, high_obs} <- CreateObservationForm.send(changeset, %{
          "has_feature_of_interest" => resource.id,
          "observed_property" => params["property"],
          "result_phenomenon" => params["phenomenon"]
        }, socket)
        do
          {:noreply,
          socket
          |> put_flash(:info, "Donation successfully recorded!")
          |> assign(all_events: [event] ++ socket.assigns.all_events)
          |> push_redirect(to: "/contribution/success/" <> e(reciprocals, :id, e(event, :id, "")))
          }
        else {_, message} ->
          error("Donation successfully recorded! #{message}", socket)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        error(message, socket)
    end
  end

  def error(message, socket) do
    {:noreply,
        socket
        |> assign(changeset: CreateEventForm.changeset(%{}))
        |> put_flash(:error, message)}
  end

  @graphql """
  {
    resource_specifications_pages(limit: 100) {
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
    observable_properties_pages(limit: 100) {
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
    economic_events_pages(limit: 100) {
      edges {
        id
        action {
          id
        }
        resource_conforms_to {
          name
        }
        triggered_by {
          action {
            id
          }
          resource_conforms_to {
            name
          }
          resource_quantity {
            has_unit {
              label
            }
            has_numerical_value
          }
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
