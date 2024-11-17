defmodule Atlas.DiscoveryTest do
  use Atlas.DataCase
  alias Atlas.Discovery

  describe "search" do
    import Atlas.MusicFixtures

    setup do
      track1 =
        track_fixture(%{
          title: "Glory Days",
          artist_name: "Bruce Springsteen",
          album_name: "Born in the U.S.A.",
          artist_id: 1,
          album_id: 1,
          number: 1
        })

      track2 =
        track_fixture(%{
          title: "Come Together",
          artist_name: "The Beatles",
          album_name: "Abbey Road",
          artist_id: 2,
          album_id: 2,
          number: 1
        })

      track3 =
        track_fixture(%{
          title: "Hungry Heart",
          artist_name: "Bruce Springsteen",
          album_name: "The River",
          artist_id: 1,
          album_id: 3,
          number: 2
        })

      {:ok, track1: track1, track2: track2, track3: track3}
    end

    test "returns exact track match as top result", %{track1: track} do
      assert %{top_result: ^track} = Discovery.search("Glory Days")
    end

    test "searching by artist name returns all tracks by that artist", %{
      track1: track1,
      track3: track3
    } do
      expected = %{
        tracks: [track1, track3],
        artists: [%{id: 1, name: "Bruce Springsteen"}],
        albums: [
          %{id: 1, name: "Born in the U.S.A."},
          %{id: 3, name: "The River"}
        ],
        top_result: track1
      }

      results = Discovery.search("Bruce")

      assert results == expected
    end

    test "searching by album name returns the album and its tracks", %{track2: track} do
      expected = %{
        tracks: [track],
        albums: [%{id: 2, name: "Abbey Road"}],
        artists: [%{id: 2, name: "The Beatles"}],
        top_result: track
      }

      results = Discovery.search("Abbey")

      assert results == expected
    end

    test "yields results irrespective of input case", %{
      track1: track1,
      track3: track3
    } do
      expected = %{
        tracks: [track1, track3],
        artists: [%{id: 1, name: "Bruce Springsteen"}]
      }

      lowercase_results = Discovery.search("bruce springsteen")
      uppercase_results = Discovery.search("BRUCE SPRINGSTEEN")
      mixed_case_results = Discovery.search("BrUcE sPrInGsTeEn")

      assert expected = lowercase_results
      assert expected = uppercase_results
      assert expected = mixed_case_results
    end

    test "yields empty results when no matches found" do
      assert %{
               tracks: [],
               artists: [],
               albums: [],
               top_result: nil
             } = Discovery.search("No Match")
    end
  end
end
