defmodule Atlas.Music.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :artist_id,
             :album_id,
             :artist_name,
             :album_name,
             :title,
             :audio_url,
             :art_url,
             :number,
             :year,
             :duration
           ]}
  schema "tracks" do
    field :title, :string
    field :number, :integer
    field :year, :string
    field :artist_id, :integer
    field :album_id, :integer
    field :artist_name, :string
    field :album_name, :string
    field :audio_url, :string
    field :art_url, :string
    field :duration, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [
      :artist_id,
      :album_id,
      :artist_name,
      :album_name,
      :title,
      :audio_url,
      :art_url,
      :number,
      :year,
      :duration
    ])
    |> validate_required([
      :artist_id,
      :album_id,
      :artist_name,
      :album_name,
      :title,
      :audio_url,
      :art_url,
      :number,
      :year,
      :duration
    ])
  end
end
