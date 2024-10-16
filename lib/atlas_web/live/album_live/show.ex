defmodule AtlasWeb.AlbumLive.Show do
  use AtlasWeb, :live_view
  use AtlasWeb.PlayerHelpers

  alias Atlas.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"album_id" => album_id}, _, socket) do
    {:noreply, assign(socket, :album, Music.list_tracks(album_id))}
  end
end
