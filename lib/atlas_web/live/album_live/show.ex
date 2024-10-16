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
    playlist = Music.list_tracks(album_id)
    socket = assign(socket, :album, playlist)

    {:noreply, push_event(socket, "liveview_loaded", %{playlist: playlist})}
  end
end
