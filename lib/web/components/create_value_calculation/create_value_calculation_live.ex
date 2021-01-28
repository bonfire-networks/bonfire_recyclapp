defmodule Bonfire.UI.Contribution.CreateValueCalculationLive do
  use Bonfire.Web, :live_component
  alias Bonfire.UI.Contribution.CreateValueCalculationForm


  def mount(socket) do
    changeset = CreateValueCalculationForm.changeset()
    {:ok, socket
    |> assign(
      changeset: changeset
    )}
  end

  def handle_event("validate_value_calculation", %{"create_value_calculation_form" => params}, socket) do
    IO.inspect(params)
    changeset = CreateValueCalculationForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit_value_calculation",  %{"create_value_calculation_form" => params}, socket) do
    changeset = CreateValueCalculationForm.changeset(params)
    case CreateValueCalculationForm.send(changeset, params, socket) do
      {:ok, vc} ->
        send self(), {:add_vc, vc}
        {:noreply, socket}
        

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)}
         |> assign(changeset: CreateValueCalculationForm.changeset(%{}))
    end
  end
  
end