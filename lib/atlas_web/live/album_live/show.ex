defmodule AtlasWeb.AlbumLive.Show do
  use AtlasWeb, :live_view
  use AtlasWeb.PlayerHelpers

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

  defp format_duration(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)

    if minutes == 0 do
      "0:#{pad(remaining_seconds)}"
    else
      "#{minutes}:#{pad(remaining_seconds)}"
    end
  end

  defp pad(number), do: String.pad_leading("#{number}", 2, "0")
end
