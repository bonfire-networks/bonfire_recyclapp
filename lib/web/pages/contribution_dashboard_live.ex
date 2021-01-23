defmodule Bonfire.UI.Contribution.ContributionDashboardLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Contribution.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}

  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  alias Bonfire.UI.Contribution.CreateEventForm

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
      high: 0,
      medium: 0,
      low: 0,
      all_resources: queries.resource_specifications,
      all_events: queries.economic_events_pages.edges,
      changeset: changeset
    )}
  end

  def handle_event("validate", %{"create_event_form" => params}, socket) do
    changeset = CreateEventForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit",  %{"create_event_form" => params}, socket) do
    changeset = CreateEventForm.changeset(params)

    case CreateEventForm.send(changeset, params, socket) do
      {:ok, event, resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Donation successfully recorded!")
         |> assign(all_events: [event] ++ socket.assigns.all_events)
       }

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
