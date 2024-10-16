defmodule AtlasWeb.ArtistLive.Show do
  use AtlasWeb, :live_view

  alias Atlas.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"artist_id" => artist_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:albums, Music.list_albums_by_artist(artist_id))}
  end

  defp page_title(:show), do: "Show Track"
  defp page_title(:edit), do: "Edit Track"
end
