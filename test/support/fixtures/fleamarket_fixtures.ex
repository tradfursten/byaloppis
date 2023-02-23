defmodule Byaloppis.FleamarketFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Byaloppis.Fleamarket` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        date: ~N[2023-02-19 20:46:00],
        description: "some description",
        name: "some name"
      })
      |> Byaloppis.Fleamarket.create_event()

    event
  end

  @doc """
  Generate a table.
  """
  def table_fixture(attrs \\ %{}) do
    {:ok, table} =
      attrs
      |> Enum.into(%{
        address: "some address",
        description: "some description",
        lat: 120.5,
        lng: 120.5
      })
      |> Byaloppis.Fleamarket.create_table()

    table
  end
end
