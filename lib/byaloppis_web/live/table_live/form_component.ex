defmodule ByaloppisWeb.TableLive.FormComponent do
  use ByaloppisWeb, :live_component

  alias Byaloppis.Fleamarket

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %> - <%= @event.name %>
        <:subtitle>Use this form to manage table records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="table-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:address]} type="text" label="Address" phx-debounce="1000" />
        <ul class="z-10 absolute bg-white/75 w-full">
          <%= for %{name: name, id: id} <- @suggestions do %>
            <li phx-target={@myself} phx-click="select_adress" phx-value-id={id}>  <%= name %> </li>
          <% end %>
        </ul>
        <div phx-hook="Map" id='map' class="rounded relative aspect-square w-full"
            style="aspect-ratio: 1 / 1; width: 100%; height: 300px" phx-update="ignore"></div>
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:lng]} type="hidden"/>
        <.input field={@form[:lat]} type="hidden"/>
        <:actions>
          <.button phx-disable-with="Saving...">Save Table</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{table: table} = assigns, socket) do
    changeset = Fleamarket.change_table(table)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"_target" => ["table", "address"], "table" => %{"address" => address} = table_params}, socket) do
    IO.puts("Search for address")
    #url = "https://1902d58c-e651-4162-a087-6564338cf4fc.mock.pstmn.io/mock_mapbox"
    url = "https://api.mapbox.com/geocoding/v5/mapbox.places/#{URI.encode(address)}.json?proximity=ip&types=place%2Cpostcode%2Caddress&access_token=#{Application.fetch_env!(:byaloppis, :mapbox_access_token)}"
    response = HTTPoison.get!(url)
    {:ok, body} = Poison.decode(response.body)
    # fixa så att vi kan hantera nil
    suggestions = body["features"]
    |> Enum.map(fn %{"place_name" => name, "geometry" => %{"coordinates" => cords}, "id" => id} -> %{name: name, cords: cords, id: id} end)

    changeset = socket.assigns.table
    |> Fleamarket.change_table(Map.merge(socket.assigns.form.params, table_params))
    |> Map.put(:action, :validate)

    socket = socket
    |> assign_form(changeset)
    |> assign(:suggestions, suggestions)
    {:noreply, socket}
  end

  @impl true
  def handle_event("select_adress", params, socket) do
    IO.inspect(socket.assigns)
    selected = socket.assigns.suggestions |> Enum.filter(fn s -> s.id == params["id"] end) |> hd
    formatted_coords = %{lng: Enum.at(selected.cords, 0), lat: Enum.at(selected.cords, 1)}

    table_params = %{"address" => selected.name, "lng" => formatted_coords.lng, "lat" => formatted_coords.lat}
    changeset = socket.assigns.table
    |> IO.inspect
    |> Fleamarket.change_table(Map.merge(socket.assigns.form.params, table_params))
    |> Map.put(:action, :validate)
    |> IO.inspect

    socket = socket
    |> assign_form(changeset)
    |> assign(coords: formatted_coords, suggestions: [])
    |> push_event("position", formatted_coords)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set_lat_lng", coords, socket) do
    IO.inspect(socket.assigns)
    changeset =
      socket.assigns.table
      |> Fleamarket.change_table(Map.merge(socket.assigns.form.params, coords))
      |> Map.put(:action, :validate)

    IO.inspect(changeset)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate", %{"table" => table_params}, socket) do
    IO.inspect(socket.assigns)
    changeset =
      socket.assigns.table
      |> Fleamarket.change_table(table_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"table" => table_params}, socket) do
    IO.inspect(socket.assigns)
    table_params = Map.merge(table_params, %{"event_id" => socket.assigns.event.id})
    IO.inspect(table_params)
    save_table(socket, socket.assigns.action, table_params)
  end

  defp save_table(socket, :edit, table_params) do
    case Fleamarket.update_table(socket.assigns.table, table_params) do
      {:ok, table} ->
        notify_parent({:saved, table})

        {:noreply,
         socket
         |> put_flash(:info, "Table updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_table(socket, :new_table, table_params) do
    IO.inspect(table_params)
    case Fleamarket.create_table(table_params) do
      {:ok, table} ->
        notify_parent({:saved, table})

        {:noreply,
         socket
         |> put_flash(:info, "Table created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    socket = socket
    |> assign(:form, to_form(changeset))
    case Map.has_key?(socket.assigns, :suggestions) do
      false -> assign(socket, :suggestions, [])
      _ -> socket
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
