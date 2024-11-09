defmodule AtlasWeb.HomeLive.Show do
  use AtlasWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{})}
  end
end
