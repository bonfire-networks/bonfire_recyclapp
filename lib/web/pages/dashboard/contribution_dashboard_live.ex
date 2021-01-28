defmodule Bonfire.UI.Contribution.ContributionDashboardLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Contribution.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  alias Bonfire.UI.Contribution.CreateEventLive

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
    {:ok, socket
    |> assign(
      page_title: "Home",
      observed: [],
      all_resources: e(queries, :resource_specifications_pages, :edges, []),
      all_events: e(queries, :economic_events_pages, :edges, []),
      all_observable_properties: e(queries, :observable_properties_pages, :edges, []),
      selected_property: List.first(e(queries, :observable_properties_pages, :edges, []))
    )}
  end

  def handle_info({:add_event, %{"event" => event, "reciprocals" => reciprocals}}, socket) do
    {:noreply,
      socket
      |> put_flash(:info, "Donation successfully recorded!")
      |> assign(all_events: [event] ++ socket.assigns.all_events)
      |> push_redirect(to: "/contribution/success/" <> e(reciprocals, :id, e(event, :id, "")))
      }
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

 
end
