defmodule AtlasWeb.ArtistLive.Index do
  use AtlasWeb, :live_view
  use AtlasWeb.PlayerHelpers

  alias Atlas.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, artists: Music.list_artists())}
  end
end
