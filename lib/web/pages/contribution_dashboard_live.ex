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
    res = all_res(socket)
    changeset = CreateEventForm.changeset()
    {:ok, socket
    |> assign(
      page_title: "Home",
      all_resources: res.resource_specifications,
      all_events: res.economic_events_pages.edges,
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
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit successfully created!")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {nil, message} ->
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
  def resource_specs(params \\ %{}, socket), do: liveql(socket, :resource_specs, params)
  def all_res(socket), do: resource_specs(socket)


end
