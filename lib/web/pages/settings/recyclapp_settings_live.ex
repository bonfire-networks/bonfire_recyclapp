defmodule Bonfire.Recyclapp.RecyclappSettingsLive do
  use Bonfire.UI.Common.Web, :live_view

  use AbsintheClient,
    schema: Bonfire.API.GraphQL.Schema,
    action: [mode: :internal]

  alias Bonfire.UI.ValueFlows.CreateUnitLive
  alias Bonfire.Recyclapp.CreateObservablePropertyLive
  alias Bonfire.UI.ValueFlows.CreateValueCalculationLive
  alias Bonfire.Recyclapp.CreatePhenomenonLive
  alias Bonfire.UI.ValueFlows.CreateResourceSpecificationLive

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, session, socket) do
    settings_queries = settings_queries(socket)

    {:ok,
     assign(
       socket,
       page_title: l("Settings"),
       all_units: e(settings_queries, :units_pages, :edges, []),
       all_resources: e(settings_queries, :resource_specifications_pages, :edges, []),
       all_properties: e(settings_queries, :observable_properties_pages, :edges, []),
       all_phenomenons: e(settings_queries, :observable_phenomenon_pages, :edges, []),
       all_value_calculations: e(settings_queries, :value_calculations_pages, :edges, []),
       actions: e(settings_queries, :actions, [])
     )}
  end

  def handle_info({:add_unit, unit}, socket) do
    {:noreply,
     socket
     |> assign(all_units: [unit] ++ assigns(socket).all_units)
     |> assign_flash(:info, "Unit successfully created!")}
  end

  def handle_info({:add_resource_specification, resource}, socket) do
    {:noreply,
     socket
     |> assign(all_units: [resource] ++ assigns(socket).all_resources)
     |> assign_flash(:info, "Resource specification successfully created!")}
  end

  def handle_info({:add_property, property}, socket) do
    {:noreply,
     socket
     |> assign_flash(:info, "Property successfully created!")
     |> assign(all_properties: [property] ++ assigns(socket).all_properties)}
  end

  def handle_info({:add_phenomenon, phenomenon}, socket) do
    {:noreply,
     socket
     |> assign_flash(:info, "Phenomenon successfully created!")
     |> assign(all_phenomenons: [phenomenon] ++ assigns(socket).all_phenomenons)}
  end

  def handle_info({:add_vc, vc}, socket) do
    {:noreply,
     socket
     |> assign_flash(:info, "Value calculation successfully created!")
     |> assign(all_value_calculations: [vc] ++ assigns(socket).all_value_calculations)}
  end

  @graphql """
    {
      units_pages(limit: 100) {
        edges {
          id
          label
          symbol
        }
      }
      observable_properties_pages(limit: 100) {
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
      observable_phenomenon_pages(limit: 100) {
        edges {
          label
          note
          formula_quantifier
          choice_of {
            label
          }
        }
      }
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
      value_calculations_pages(limit: 100) {
         edges {
          id
          note
          name
         }
      }
    }
  """

  def settings_queries(params \\ %{}, socket),
    do: liveql(socket, :settings_queries, params)
end
