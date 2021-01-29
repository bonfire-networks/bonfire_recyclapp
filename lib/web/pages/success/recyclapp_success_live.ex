defmodule Bonfire.Recyclapp.RecyclappSuccessLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.Recyclapp.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias QRCode.QR
  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  alias Bonfire.Recyclapp.CreateEventForm
  alias Bonfire.Recyclapp.CreateObservationForm

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(%{"reciprocal_id"=> reciprocal_id}, session, socket) do

    IO.inspect(reciprocal_id)
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
