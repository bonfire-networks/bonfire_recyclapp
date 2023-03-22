defmodule Bonfire.Recyclapp.RecyclappSuccessLive do
  use Bonfire.UI.Common.Web, :live_view

  use AbsintheClient,
    schema: Bonfire.API.GraphQL.Schema,
    action: [mode: :internal]

  alias Bonfire.UI.Social.HashtagsLive
  alias Bonfire.UI.Social.ParticipantsLive

  alias Bonfire.Me.Users
  alias Bonfire.UI.Me.CreateUserLive
  alias Bonfire.Recyclapp.CreateEventForm
  alias Bonfire.Recyclapp.CreateObservationForm

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(%{"reciprocal_id" => reciprocal_id}, session, socket) do
    debug(reciprocal_id)
    reciprocal = reciprocal_by_id(reciprocal_id, socket)

    {:ok,
     assign(
       socket,
       page_title: "Success",
       reciprocal: reciprocal.economic_event
     )}
  end

  def mount(params, session, socket) do
    {:ok,
     assign(
       socket,
       page_title: "Recyclapp",
       selected_tab: "about",
       reciprocal: nil
     )}
  end

  @graphql """
    query($id: ID) {
      economic_event(id: $id) {
        id
        note
        resource_quantity {
          has_numerical_value
          has_unit {
            label
          }
        }
        resource_conforms_to {
          id
          name
        }
        provider
        receiver
        at_location

      }
    }
  """

  def queries(params \\ %{}, socket), do: liveql(socket, :queries, params)
  def reciprocal_by_id(id, socket), do: queries(%{id: id}, socket)
end
