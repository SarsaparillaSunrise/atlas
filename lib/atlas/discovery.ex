defmodule Atlas.Discovery do
  import Ecto.Query, warn: false
  alias Atlas.Repo
  alias Atlas.Music.Track

  def search(query) do
    tracks = search_tracks(query)

    # Extract unique artists and albums from tracks
    artists =
      tracks
      |> Enum.map(&%{id: &1.artist_id, name: &1.artist_name})
      |> Enum.uniq_by(& &1.id)

    albums =
      tracks
      |> Enum.map(&%{id: &1.album_id, name: &1.album_name})
      |> Enum.uniq_by(& &1.id)

    # Find best match for top result
    top_result = determine_top_result(query, tracks)

    %{
      top_result: top_result,
      artists: artists,
      albums: albums,
      tracks: tracks
    }
  end

  def empty_results do
    %{
      top_result: nil,
      artists: [],
      albums: [],
      tracks: []
    }
  end

  defp search_tracks(query) do
    normalized_query = "%#{String.downcase(query)}%"

    from(t in Track,
      where:
        ilike(t.title, ^normalized_query) or
          ilike(t.artist_name, ^normalized_query) or
          ilike(t.album_name, ^normalized_query),
      order_by: [
        # Exact matches first
        desc:
          fragment(
            "CASE
          WHEN LOWER(title) = ? THEN 2
          WHEN LOWER(artist_name) = ? THEN 1
          WHEN LOWER(album_name) = ? THEN 1
          ELSE 0 END",
            ^String.downcase(query),
            ^String.downcase(query),
            ^String.downcase(query)
          ),
        # Then by relevance
        asc: t.artist_name,
        asc: t.album_name,
        asc: t.number
      ]
    )
    |> Repo.all()
  end

  defp determine_top_result(query, tracks) do
    normalized_query = String.downcase(query)

    Enum.find(tracks, List.first(tracks), fn track ->
      String.downcase(track.title) == normalized_query ||
        String.downcase(track.artist_name) == normalized_query ||
        String.downcase(track.album_name) == normalized_query
    end)
  end
end
