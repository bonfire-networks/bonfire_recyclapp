defmodule Bonfire.Recyclapp.CreateObservablePropertyLive do
  use Bonfire.UI.Common.Web, :live_component
  alias Bonfire.Recyclapp.CreateObservablePropertyForm


  def mount(socket) do
    changeset = CreateObservablePropertyForm.changeset()
    {:ok, socket
    |> assign(
      changeset: changeset
    )}
  end

  def handle_event("validate_property", %{"create_observable_property_form" => params}, socket) do
    changeset = CreateObservablePropertyForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_property",  %{"create_observable_property_form" => params}, socket) do
    changeset = CreateObservablePropertyForm.changeset(params)

    case CreateObservablePropertyForm.send(changeset, params, socket) do
      {:ok, property} ->
        send self(), {:add_property, property}
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset_property: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> assign_flash(:error, message)}
         |> assign(changeset: CreateObservablePropertyForm.changeset(%{}))
    end
  end

end
