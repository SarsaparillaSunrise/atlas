defmodule Atlas.Music do
  @moduledoc """
  The Music context.
  """

  import Ecto.Query, warn: false
  alias Atlas.Repo

  alias Atlas.Music.Track

  @doc """
  Returns the list of tracks.

  ## Examples

      iex> list_tracks()
      [%Track{}, ...]

  """
  def list_tracks do
    Repo.all(Track)
  end

  @doc """
  Gets a single track.

  Raises `Ecto.NoResultsError` if the Track does not exist.

  ## Examples

      iex> get_track!(123)
      %Track{}

      iex> get_track!(456)
      ** (Ecto.NoResultsError)

  """
  def get_track!(id), do: Repo.get!(Track, id)

  @doc """
  Creates a track.

  ## Examples

      iex> create_track(%{field: value})
      {:ok, %Track{}}

      iex> create_track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_track(attrs \\ %{}) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a track.

  ## Examples

      iex> update_track(track, %{field: new_value})
      {:ok, %Track{}}

      iex> update_track(track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_track(%Track{} = track, attrs) do
    track
    |> Track.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a track.

  ## Examples

      iex> delete_track(track)
      {:ok, %Track{}}

      iex> delete_track(track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_track(%Track{} = track) do
    Repo.delete(track)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking track changes.

  ## Examples

      iex> change_track(track)
      %Ecto.Changeset{data: %Track{}}

  """
  def change_track(%Track{} = track, attrs \\ %{}) do
    Track.changeset(track, attrs)
  end

  @doc """
  Retrieves a list of unique artists from the tracks database.

  Each artist is represented by their `artist_id`, `artist_name`, and an associated `art_url`.
  The `art_url` is selected arbitrarily from the artist's tracks.

  ## Examples

      iex> list_artists()
      [
        %{artist_id: 1, artist_name: "Artist One", art_url: "http://example.com/art1.jpg"},
        %{artist_id: 2, artist_name: "Artist Two", art_url: "http://example.com/art2.jpg"}
      ]

  Returns a list of maps where each map contains:
    - `:artist_id` - The unique identifier for the artist.
    - `:artist_name` - The name of the artist.
    - `:art_url` - An arbitrary album art URL associated with the artist.
  """
  def list_artists do
    Repo.all(
      from t in Track,
        group_by: [t.artist_id, t.artist_name],
        select: %{artist_id: t.artist_id, artist_name: t.artist_name, art_url: min(t.art_url)},
        # Correct artist sort order:
        order_by:
          fragment(
            "CASE WHEN LOWER(LEFT(?, 4)) = 'the ' THEN LOWER(SUBSTRING(?, 5)) ELSE LOWER(?) END",
            t.artist_name,
            t.artist_name,
            t.artist_name
          )
    )
  end
end
