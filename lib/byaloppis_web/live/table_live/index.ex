defmodule ByaloppisWeb.TableLive.Index do
  use ByaloppisWeb, :live_view

  alias Byaloppis.Fleamarket
  alias Byaloppis.Fleamarket.Table

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tables, Fleamarket.list_tables())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Table")
    |> assign(:table, Fleamarket.get_table!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Table")
    |> assign(:table, %Table{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tables")
    |> assign(:table, nil)
  end

  @impl true
  def handle_info({ByaloppisWeb.TableLive.FormComponent, {:saved, table}}, socket) do
    {:noreply, stream_insert(socket, :tables, table)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    table = Fleamarket.get_table!(id)
    {:ok, _} = Fleamarket.delete_table(table)

    {:noreply, stream_delete(socket, :tables, table)}
  end


end
