defmodule Bonfire.Recyclapp.RecyclappDashboardLive do
  use Bonfire.UI.Common.Web, :live_view

  use AbsintheClient,
    schema: Bonfire.API.GraphQL.Schema,
    action: [mode: :internal]

  alias Bonfire.Me.Users
  alias Bonfire.UI.Me.CreateUserLive
  alias Bonfire.Recyclapp.CreateEventLive

  declare_extension("EveryCycle",
    icon: "icon-park-outline:cycle",
    emoji: "🌀",
    description: l("Circle of life.")
  )

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, session, socket) do
    queries = queries(socket)
    events = e(queries, :economic_events_pages, :edges, [])

    {:ok,
     assign(
       socket,
       page_title: "Home",
       observed: [],
       all_resources: e(queries, :resource_specifications_pages, :edges, []),
       all_events: Enum.filter(events, fn ev -> ev.triggered_by != nil end),
       all_observable_properties: e(queries, :observable_properties_pages, :edges, []),
       selected_property: List.first(e(queries, :observable_properties_pages, :edges, []))
     )}
  end

  def handle_info(
        {:add_event, %{"event" => event, "reciprocals" => reciprocals}},
        socket
      ) do
    {:noreply,
     socket
     |> assign_flash(:info, "Donation successfully recorded!")
     |> assign(all_events: [event] ++ assigns(socket).all_events)
     |> redirect_to("/recyclapp/success/" <> e(reciprocals, :id, e(event, :id, "")))}
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
end
