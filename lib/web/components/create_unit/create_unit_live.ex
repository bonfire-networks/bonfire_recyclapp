defmodule Bonfire.UI.Contribution.CreateUnitLive do
  use Bonfire.Web, :live_component
  alias Bonfire.UI.Contribution.CreateUnitForm


  def mount(socket) do
    changeset = CreateUnitForm.changeset()
    {:ok, socket
    |> assign(
      changeset: changeset
    )}
  end

  def handle_event("validate_unit", %{"create_unit_form" => params}, socket) do
    changeset = CreateUnitForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_unit",  %{"create_unit_form" => params}, socket) do
    changeset = CreateUnitForm.changeset(params)

    case CreateUnitForm.send(changeset, params, socket) do
      {:ok, unit} ->
        send self(), {:add_unit, unit}
        {:noreply,
         socket
         
        #  |> assign(all_units: [unit] ++ socket.assigns.all_units)
       }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
         |> assign(changeset: CreateUnitForm.changeset(%{}))
    end
  end

end
