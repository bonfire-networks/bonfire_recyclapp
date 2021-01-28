defmodule Bonfire.UI.Contribution.CreateResourceSpecificationLive do
  use Bonfire.Web, :live_component
  alias Bonfire.UI.Contribution.CreateResourceSpecForm


  def mount(socket) do
    changeset = CreateResourceSpecForm.changeset()
    {:ok, socket
    |> assign(
      changeset: changeset
    )}
  end

  
  def handle_event("validate_resource", %{"create_resource_spec_form" => params}, socket) do
    IO.inspect(params)
    changeset = CreateResourceSpecForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_resource",  %{"create_resource_spec_form" => params}, socket) do
    changeset = CreateResourceSpecForm.changeset(params)

    case CreateResourceSpecForm.send(changeset, params, socket) do
      {:ok, resource} ->
        send self(), {:add_resource_specification, resource}
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> assign(changeset: CreateResourceSpecForm.changeset(%{}))
         |> put_flash(:error, message)}
    end
  end

end
