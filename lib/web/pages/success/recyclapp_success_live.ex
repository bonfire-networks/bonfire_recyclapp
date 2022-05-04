defmodule Bonfire.Recyclapp.RecyclappSuccessLive do
  use Bonfire.UI.Common.Web, {:live_view, [layout: {Bonfire.Recyclapp.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.API.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias QRCode.QR
  alias Bonfire.Me.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.CreateUserLive
  alias Bonfire.Recyclapp.CreateEventForm
  alias Bonfire.Recyclapp.CreateObservationForm

  def mount(params, session, socket) do
    live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(%{"reciprocal_id"=> reciprocal_id}, session, socket) do

    debug(reciprocal_id)
    reciprocal = reciprocal_by_id(reciprocal_id, socket)

    {:ok, socket
    |> assign(page_title: "Success",
    reciprocal: reciprocal.economic_event,
    )}
  end

  defp mounted(params, session, socket) do

    {:ok, socket
    |> assign(page_title: "Recyclapp",
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
