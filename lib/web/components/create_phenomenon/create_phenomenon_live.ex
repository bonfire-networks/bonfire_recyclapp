defmodule Bonfire.UI.Contribution.CreatePhenomenonLive do
  use Bonfire.Web, :live_component
  alias Bonfire.UI.Contribution.CreatePhenomenonForm


  def mount(socket) do
    changeset = CreatePhenomenonForm.changeset()
    {:ok, socket
    |> assign(
      changeset: changeset
    )}
  end

  def handle_event("validate_phenomenon", %{"create_phenomenon_form" => params}, socket) do
    changeset = CreatePhenomenonForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_phenomenon",  %{"create_phenomenon_form" => params}, socket) do
    changeset = CreatePhenomenonForm.changeset(params)

    case CreatePhenomenonForm.send(changeset, params, socket) do
      {:ok, phenomenon} ->
        {:noreply,
         socket
         |> put_flash(:info, "Phenomenon successfully created!")
         |> assign(all_phenomenons: [phenomenon] ++ socket.assigns.all_phenomenons)
       }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset_property: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)
         |> assign(changeset: CreatePhenomenonForm.changeset(%{}))
        }
    end
  end


end