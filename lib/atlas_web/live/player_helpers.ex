defmodule AtlasWeb.PlayerHelpers do
  defmacro __using__(_opts) do
    quote do
      @impl true
      def handle_event("play_pause", _, socket) do
        {:noreply, push_event(socket, "play_pause", %{})}
      end

      @impl true
      def handle_event("play_prev", _, socket) do
        IO.puts("play_prev #")
        {:noreply, push_event(socket, "play_prev", %{})}
      end

      @impl true
      def handle_event("play_next", _, socket) do
        {:noreply, push_event(socket, "play_next", %{})}
      end

      @impl true
      def handle_event("select_track", %{"track-id" => id}, socket) do
        {:noreply, push_event(socket, "select_track", %{track_id: id})}
      end
    end
  end
end
