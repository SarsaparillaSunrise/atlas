defmodule AtlasWeb.HomeLive.Show do
  use AtlasWeb, :live_view
  use AtlasWeb.PlayerHelpers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{})}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
