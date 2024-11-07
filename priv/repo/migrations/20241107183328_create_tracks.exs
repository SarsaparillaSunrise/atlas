defmodule Atlas.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :artist_id, :integer
      add :album_id, :integer
      add :artist_name, :string
      add :album_name, :string
      add :title, :string
      add :audio_url, :string
      add :art_url, :string
      add :number, :integer
      add :year, :string
      add :duration, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
