defmodule Bonfire.UI.Contribution.ContributionSuccessLive do
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

  defp mounted(%{"reciprocal_id"=> reciprocal_id}, session, socket) do
    
    reciprocal = reciprocal_by_id(reciprocal_id, socket)
    IO.inspect(reciprocal)

    {:ok, socket
    |> assign(page_title: "Success",
    reciprocal: reciprocal,

    )}
  end

  defp mounted(params, session, socket) do

    {:ok, socket
    |> assign(page_title: "Proposal",
    selected_tab: "about",
    reciprocal: nil
    )}
  end

  @graphql """
    query($id: ID) {
      economic_event(id: $id) {
        id
        note
        provider
        receiver
        at_location

      }
    }
  """
  def reciprocal(params, socket), do: []
  def reciprocal_by_id(id, socket), do: reciprocal(%{id: id}, socket)





end
