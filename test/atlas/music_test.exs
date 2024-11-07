defmodule Atlas.MusicTest do
  use Atlas.DataCase

  alias Atlas.Music

  describe "tracks" do
    alias Atlas.Music.Track

    import Atlas.MusicFixtures

    @invalid_attrs %{title: nil, number: nil, year: nil, artist_id: nil, album_id: nil, artist_name: nil, album_name: nil, audio_url: nil, art_url: nil, duration: nil}

    test "list_tracks/0 returns all tracks" do
      track = track_fixture()
      assert Music.list_tracks() == [track]
    end

    test "get_track!/1 returns the track with given id" do
      track = track_fixture()
      assert Music.get_track!(track.id) == track
    end

    test "create_track/1 with valid data creates a track" do
      valid_attrs = %{title: "some title", number: 42, year: "some year", artist_id: 42, album_id: 42, artist_name: "some artist_name", album_name: "some album_name", audio_url: "some audio_url", art_url: "some art_url", duration: 42}

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
      update_attrs = %{title: "some updated title", number: 43, year: "some updated year", artist_id: 43, album_id: 43, artist_name: "some updated artist_name", album_name: "some updated album_name", audio_url: "some updated audio_url", art_url: "some updated art_url", duration: 43}

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
  end
end
