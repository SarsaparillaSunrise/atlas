defmodule AtlasWeb.TrackLive.Index do
  use AtlasWeb, :live_view

  alias Atlas.Music
  alias Atlas.Music.Track

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tracks, Music.list_tracks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Track")
    |> assign(:track, Music.get_track!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Track")
    |> assign(:track, %Track{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tracks")
    |> assign(:track, nil)
  end

  @impl true
  def handle_info({AtlasWeb.TrackLive.FormComponent, {:saved, track}}, socket) do
    {:noreply, stream_insert(socket, :tracks, track)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    track = Music.get_track!(id)
    {:ok, _} = Music.delete_track(track)

    {:noreply, stream_delete(socket, :tracks, track)}
  end
end
