defmodule ByaloppisWeb.EventLive.Show do
  use ByaloppisWeb, :live_view

  alias Byaloppis.Fleamarket

  @impl true
  def mount(_params, _session, socket) do
    IO.puts("Mounted show event")
    IO.inspect(socket.assigns)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    IO.puts("handle params")
    event = Fleamarket.get_event!(id)

    list_tables = event.tables
    |> Enum.map(fn t -> %{lng: t.lng, lat: t.lat, address: t.address, id: t.id} end)
    socket = socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:event, event)
    |> push_event("list_tables", %{tables: list_tables})
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Event"
  defp page_title(:edit), do: "Edit Event"
end
