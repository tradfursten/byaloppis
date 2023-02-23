defmodule Byaloppis.Fleamarket.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Byaloppis.Fleamarket.Table

  schema "events" do
    field :date, :naive_datetime
    field :description, :string
    field :name, :string

    has_many :tables, Table

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :date, :description])
    |> validate_required([:name, :date, :description])
  end
end
