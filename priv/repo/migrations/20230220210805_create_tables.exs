defmodule Byaloppis.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tables) do
      add :address, :string
      add :description, :text
      add :lng, :float
      add :lat, :float
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    create index(:tables, [:event_id])
  end
end
