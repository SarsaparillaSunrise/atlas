defmodule Atlas.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :artist_id, :integer, null: false
      add :album_id, :integer, null: false
      add :artist_name, :string, null: false
      add :album_name, :string, null: false
      add :title, :string, null: false
      add :audio_url, :string, null: false
      add :art_url, :string, null: false
      add :number, :integer, null: false
      add :year, :string, null: false
      add :length, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tracks, [:artist_id])
    create index(:tracks, [:album_id])
    create index(:tracks, [:artist_name])
    create index(:tracks, [:album_name])
    create index(:tracks, [:title])

    create index(:tracks, [:artist_id, :album_id])
    create index(:tracks, [:artist_name, :album_name, :title])
  end
end
