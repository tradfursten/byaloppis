defmodule Byaloppis.Fleamarket.Table do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tables" do
    field :address, :string
    field :description, :string
    field :lat, :float
    field :lng, :float
    field :event_id, :id

    timestamps()
  end

  @doc false
  def changeset(table, attrs) do
    table
    |> cast(attrs, [:address, :description, :lng, :lat])
    |> validate_required([:address, :description, :lng, :lat])
  end
end
