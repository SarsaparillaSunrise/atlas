defmodule AtlasWeb.HomeLive.Show do
  use AtlasWeb, :live_view
  alias Atlas.Discovery

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:query, nil)
     |> assign(:results, Discovery.empty_results())}
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    results = Discovery.search(query)
    {:noreply, assign(socket, results: results, query: query)}
  end

  def handle_event("clear_results", _, socket) do
    {:noreply, assign(socket, results: Discovery.empty_results(), query: nil)}
  end
end
