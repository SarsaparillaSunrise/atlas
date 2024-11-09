defmodule AtlasWeb.AlbumLive.Show do
  use AtlasWeb, :live_view

  alias Atlas.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => album_id}, _, socket) do
    playlist = Music.list_album_tracks(album_id)
    socket = assign(socket, :album, playlist)

    {:noreply, push_event(socket, "liveview_loaded", %{playlist: playlist})}
  end
end
