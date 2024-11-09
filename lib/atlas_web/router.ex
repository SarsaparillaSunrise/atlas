defmodule AtlasWeb.Router do
  use AtlasWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AtlasWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AtlasWeb do
    pipe_through :browser

    live "/", HomeLive.Show, :show

    live "/artists", ArtistLive.Index, :index
    live "/artists/:id/albums", ArtistLive.Show, :show

    live "/tracks", TrackLive.Index, :index
    live "/tracks/new", TrackLive.Index, :new
    live "/tracks/:id/edit", TrackLive.Index, :edit

    live "/tracks/:id", TrackLive.Show, :show
    live "/tracks/:id/show/edit", TrackLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", AtlasWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:atlas, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AtlasWeb.Telemetry
    end
  end
end
