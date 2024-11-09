defmodule AtlasWeb.ArtistLive.Show do
  use AtlasWeb, :live_view

  alias Atlas.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => artist_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:albums, Music.list_albums_by_artist(artist_id))}
  end
end
