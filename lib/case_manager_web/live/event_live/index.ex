defmodule CaseManagerWeb.EventLive.Index do
  use CaseManagerWeb, :live_view

  alias CaseManager.Events
  alias CaseManager.Events.Event
  import CaseManagerWeb.LiveUtils

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Events.subscribe()
    {:ok, stream(socket, :events, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Events.get_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add Manual Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, params) do
    case Events.list_events(params) do
      {:ok, {events, meta}} ->
        socket
        |> assign(:meta, meta)
        |> stream(:events, events, reset: true)
        |> assign(:page_title, "Listing Events")
        |> assign(:event, nil)

      {:error, _meta} ->
        # This will reset invalid parameters. Alternatively, you can assign
        # only the meta and render the errors, or you can ignore the error
        # case entirely.
        push_navigate(socket, to: ~p"/events")
    end
  end

  @impl true
  def handle_info({:event_created, event}, socket) do
    {:noreply, stream_insert(socket, :events, event, at: 0)}
  end

  @impl true
  def handle_info({:event_updated, event}, socket) do
    {:noreply, stream_insert(socket, :events, event, at: 0)}
  end

  @impl true
  def handle_info({CaseManagerWeb.EventLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end
end
