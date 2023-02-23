defmodule ByaloppisWeb.TableLive.Show do
  use ByaloppisWeb, :live_view

  alias Byaloppis.Fleamarket

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:table, Fleamarket.get_table!(id))}
  end

  defp page_title(:show), do: "Show Table"
  defp page_title(:edit), do: "Edit Table"
end
