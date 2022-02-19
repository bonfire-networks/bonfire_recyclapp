defmodule Bonfire.Recyclapp.CreateEventLive do
  use Bonfire.Web, :live_component
  alias Bonfire.Recyclapp.CreateEventForm
  alias Bonfire.Recyclapp.CreateObservationForm


  def mount(socket) do
    changeset = CreateEventForm.changeset()
    {:ok, socket
    |> assign(
      changeset: changeset
    )}
  end

  def handle_event("add_observation", %{"id" => id}, socket) do
    cond do
      Enum.member?(socket.assigns.observed, id) == false ->
        socket = assign(socket, observed: [id] ++ socket.assigns.observed)
        {:noreply, socket}
      Enum.member?(socket.assigns.observed, id) == true ->
        socket = assign(socket, observed: List.delete(socket.assigns.observed, id))
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"create_event_form" => params}, socket) do
    debug(validate: params)

    changeset = CreateEventForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit",  %{"create_event_form" => params}, socket) do
    debug(submit: params)
    changeset = CreateEventForm.changeset(params)
      # has_result = %{
      #   unit: resource_spec.default_unit_of_effort,
      #   has_numerical_value: high
      # }
      # CreateObservationForm.send(changeset, %{has_feature_of_interest: resource.id, observed_property: property, }, socket)
      # def send(changeset, %{"has_feature_of_interest" => has_feature_of_interest, "observed_property" => observed_property, "has_result" => has_result, "unit" => unit} = _params, socket) do

   case CreateEventForm.send(changeset, params, socket) do
    {:ok, %{economic_event: event, reciprocal_events: reciprocals, economic_resource: resource}} ->
      debug(reciprocals)
        with {:ok, high_obs} <- CreateObservationForm.send(changeset, %{
          "has_feature_of_interest" => resource.id,
          "observed_property" => params["property"],
          "result_phenomenon" => params["phenomenon"]
        }, socket)
        do
          send self(), {:add_event, %{"event" => event, "reciprocals" => reciprocals}}
          {:noreply, socket}

        else {_, message} ->
          error("Donation successfully recorded! #{message}", socket)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {_, message} ->
        error(message, socket)
    end
  end

  def error(message, socket) do
    {:noreply,
        socket
        |> assign(changeset: CreateEventForm.changeset(%{}))
        |> put_flash(:error, message)}
  end

  def spec_unit(spec) do
    unit = e(spec, :default_unit_of_effort, :label, nil)
    if unit do
      " (#{unit})"
    else
      ""
    end
  end
end
