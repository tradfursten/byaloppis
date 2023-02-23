defmodule Byaloppis.FleamarketTest do
  use Byaloppis.DataCase

  alias Byaloppis.Fleamarket

  describe "events" do
    alias Byaloppis.Fleamarket.Event

    import Byaloppis.FleamarketFixtures

    @invalid_attrs %{date: nil, description: nil, name: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Fleamarket.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Fleamarket.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{date: ~N[2023-02-19 20:46:00], description: "some description", name: "some name"}

      assert {:ok, %Event{} = event} = Fleamarket.create_event(valid_attrs)
      assert event.date == ~N[2023-02-19 20:46:00]
      assert event.description == "some description"
      assert event.name == "some name"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleamarket.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{date: ~N[2023-02-20 20:46:00], description: "some updated description", name: "some updated name"}

      assert {:ok, %Event{} = event} = Fleamarket.update_event(event, update_attrs)
      assert event.date == ~N[2023-02-20 20:46:00]
      assert event.description == "some updated description"
      assert event.name == "some updated name"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleamarket.update_event(event, @invalid_attrs)
      assert event == Fleamarket.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Fleamarket.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Fleamarket.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Fleamarket.change_event(event)
    end
  end

  describe "tables" do
    alias Byaloppis.Fleamarket.Table

    import Byaloppis.FleamarketFixtures

    @invalid_attrs %{address: nil, description: nil, lat: nil, lng: nil}

    test "list_tables/0 returns all tables" do
      table = table_fixture()
      assert Fleamarket.list_tables() == [table]
    end

    test "get_table!/1 returns the table with given id" do
      table = table_fixture()
      assert Fleamarket.get_table!(table.id) == table
    end

    test "create_table/1 with valid data creates a table" do
      valid_attrs = %{address: "some address", description: "some description", lat: 120.5, lng: 120.5}

      assert {:ok, %Table{} = table} = Fleamarket.create_table(valid_attrs)
      assert table.address == "some address"
      assert table.description == "some description"
      assert table.lat == 120.5
      assert table.lng == 120.5
    end

    test "create_table/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleamarket.create_table(@invalid_attrs)
    end

    test "update_table/2 with valid data updates the table" do
      table = table_fixture()
      update_attrs = %{address: "some updated address", description: "some updated description", lat: 456.7, lng: 456.7}

      assert {:ok, %Table{} = table} = Fleamarket.update_table(table, update_attrs)
      assert table.address == "some updated address"
      assert table.description == "some updated description"
      assert table.lat == 456.7
      assert table.lng == 456.7
    end

    test "update_table/2 with invalid data returns error changeset" do
      table = table_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleamarket.update_table(table, @invalid_attrs)
      assert table == Fleamarket.get_table!(table.id)
    end

    test "delete_table/1 deletes the table" do
      table = table_fixture()
      assert {:ok, %Table{}} = Fleamarket.delete_table(table)
      assert_raise Ecto.NoResultsError, fn -> Fleamarket.get_table!(table.id) end
    end

    test "change_table/1 returns a table changeset" do
      table = table_fixture()
      assert %Ecto.Changeset{} = Fleamarket.change_table(table)
    end
  end
end
