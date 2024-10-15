defmodule AtlasWeb.ArtistLive.Index do
  use AtlasWeb, :live_view

  alias Atlas.Music

  @impl true
  def mount(_params, _session, socket) do
    playlist = Music.list_tracks()
    payload = %{playlist: playlist}
    assign(socket, artists: playlist)
    {:ok, push_event(socket, "liveview_loaded", payload)}
  end

  @impl true
  def handle_event("play_pause", _, socket) do
    {:noreply, push_event(socket, "play_pause", %{})}
  end

  def handle_event("play_prev", _, socket) do
    IO.puts("play_prev #")
    {:noreply, push_event(socket, "play_prev", %{})}
  end

  def handle_event("play_next", _, socket) do
    {:noreply, push_event(socket, "play_next", %{})}
  end

  def handle_event("select_track", %{"track-id" => id}, socket) do
    {:noreply, push_event(socket, "select_track", %{track_id: id})}
  end
end
