defmodule Atlas.MusicFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.Music` context.
  """

  @doc """
  Generate a track.
  """
  def track_fixture(attrs \\ %{}) do
    {:ok, track} =
      attrs
      |> Enum.into(%{
        album_id: 42,
        album_name: "some album_name",
        art_url: "some art_url",
        artist_id: 42,
        artist_name: "some artist_name",
        audio_url: "some audio_url",
        duration: 42,
        number: 42,
        title: "some title",
        year: "some year"
      })
      |> Atlas.Music.create_track()

    track
  end
end
