defmodule ByaloppisWeb.EventLive.Index do
  use ByaloppisWeb, :live_view

  alias Byaloppis.Fleamarket
  alias Byaloppis.Fleamarket.Event
  alias Byaloppis.Fleamarket.Table

  @impl true
  def mount(_params, _session, socket) do
    events = Fleamarket.list_events_with_tables()
    IO.inspect(events)
    {:ok, stream(socket, :events, events)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Fleamarket.get_event!(id))
  end

  defp apply_action(socket, :new_table, %{"id" => id}) do
    socket
    |> assign(:page_title, "New Table")
    |> assign(:event, Fleamarket.get_event!(id))
    |> assign(:table, %Table{})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_info({ByaloppisWeb.EventLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Fleamarket.get_event!(id)
    {:ok, _} = Fleamarket.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end
end
