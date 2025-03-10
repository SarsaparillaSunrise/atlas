defmodule Atlas.MusicTest do
  use Atlas.DataCase

  alias Atlas.Music

  describe "tracks" do
    alias Atlas.Music.Track

    import Atlas.MusicFixtures

    @invalid_attrs %{
      title: nil,
      number: nil,
      year: nil,
      artist_id: nil,
      album_id: nil,
      artist_name: nil,
      album_name: nil,
      audio_url: nil,
      art_url: nil,
      duration: nil
    }

    test "list_tracks/0 returns all tracks" do
      track = track_fixture()
      assert Music.list_tracks() == [track]
    end

    test "get_track!/1 returns the track with given id" do
      track = track_fixture()
      assert Music.get_track!(track.id) == track
    end

    test "create_track/1 with valid data creates a track" do
      valid_attrs = %{
        title: "some title",
        number: 42,
        year: "some year",
        artist_id: 42,
        album_id: 42,
        artist_name: "some artist_name",
        album_name: "some album_name",
        audio_url: "some audio_url",
        art_url: "some art_url",
        duration: 42
      }

      assert {:ok, %Track{} = track} = Music.create_track(valid_attrs)
      assert track.title == "some title"
      assert track.number == 42
      assert track.year == "some year"
      assert track.artist_id == 42
      assert track.album_id == 42
      assert track.artist_name == "some artist_name"
      assert track.album_name == "some album_name"
      assert track.audio_url == "some audio_url"
      assert track.art_url == "some art_url"
      assert track.duration == 42
    end

    test "create_track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Music.create_track(@invalid_attrs)
    end

    test "update_track/2 with valid data updates the track" do
      track = track_fixture()

      update_attrs = %{
        title: "some updated title",
        number: 43,
        year: "some updated year",
        artist_id: 43,
        album_id: 43,
        artist_name: "some updated artist_name",
        album_name: "some updated album_name",
        audio_url: "some updated audio_url",
        art_url: "some updated art_url",
        duration: 43
      }

      assert {:ok, %Track{} = track} = Music.update_track(track, update_attrs)
      assert track.title == "some updated title"
      assert track.number == 43
      assert track.year == "some updated year"
      assert track.artist_id == 43
      assert track.album_id == 43
      assert track.artist_name == "some updated artist_name"
      assert track.album_name == "some updated album_name"
      assert track.audio_url == "some updated audio_url"
      assert track.art_url == "some updated art_url"
      assert track.duration == 43
    end

    test "update_track/2 with invalid data returns error changeset" do
      track = track_fixture()
      assert {:error, %Ecto.Changeset{}} = Music.update_track(track, @invalid_attrs)
      assert track == Music.get_track!(track.id)
    end

    test "delete_track/1 deletes the track" do
      track = track_fixture()
      assert {:ok, %Track{}} = Music.delete_track(track)
      assert_raise Ecto.NoResultsError, fn -> Music.get_track!(track.id) end
    end

    test "change_track/1 returns a track changeset" do
      track = track_fixture()
      assert %Ecto.Changeset{} = Music.change_track(track)
    end

    test "sorts artists ignoring 'The'" do
      track_fixture(%{artist_name: "The 1975"})
      track_fixture(%{artist_name: "Tenacious D"})
      track_fixture(%{artist_name: "The Ataris"})

      assert Music.list_artists() |> Enum.map(& &1.artist_name) == [
               "The 1975",
               "The Ataris",
               "Tenacious D"
             ]
    end

    test "lists albums for a specific artist with proper grouping" do
      artist_id = 1
      # An artist with two albums
      track_fixture(%{artist_id: artist_id, album_id: 101, album_name: "First Album"})
      track_fixture(%{artist_id: artist_id, album_id: 102, album_name: "Second Album"})

      # Control case - different artist's album
      track_fixture(%{artist_id: 2})

      albums = Music.list_albums_by_artist(artist_id)

      assert [
               %{album_id: 102, album_name: "Second Album"},
               %{album_id: 101, album_name: "First Album"}
             ] = Enum.map(albums, &Map.take(&1, [:album_id, :album_name]))
    end

    test "lists tracks for an album in track number order" do
      album_id = 1

      # Create tracks in non-sequential order to verify sorting
      track_fixture(%{album_id: album_id, number: 3, title: "Track Three"})
      track_fixture(%{album_id: album_id, number: 1, title: "Track One"})
      track_fixture(%{album_id: album_id, number: 2, title: "Track Two"})

      # Control case - track from different album
      _other_track = track_fixture(%{album_id: 2, number: 1})

      tracks = Music.list_album_tracks(album_id)

      assert [
               %{number: 1, title: "Track One"},
               %{number: 2, title: "Track Two"},
               %{number: 3, title: "Track Three"}
             ] = Enum.map(tracks, &Map.take(&1, [:number, :title]))
    end
  end
end
