defmodule AtlasWeb.TrackLive.FormComponent do
  use AtlasWeb, :live_component

  alias Atlas.Music

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage track records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="track-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:artist_id]} type="number" label="Artist" />
        <.input field={@form[:album_id]} type="number" label="Album" />
        <.input field={@form[:artist_name]} type="text" label="Artist name" />
        <.input field={@form[:album_name]} type="text" label="Album name" />
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:audio_url]} type="text" label="Audio url" />
        <.input field={@form[:art_url]} type="text" label="Art url" />
        <.input field={@form[:number]} type="number" label="Number" />
        <.input field={@form[:year]} type="text" label="Year" />
        <.input field={@form[:duration]} type="number" label="Duration" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Track</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{track: track} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Music.change_track(track))
     end)}
  end

  @impl true
  def handle_event("validate", %{"track" => track_params}, socket) do
    changeset = Music.change_track(socket.assigns.track, track_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"track" => track_params}, socket) do
    save_track(socket, socket.assigns.action, track_params)
  end

  defp save_track(socket, :edit, track_params) do
    case Music.update_track(socket.assigns.track, track_params) do
      {:ok, track} ->
        notify_parent({:saved, track})

        {:noreply,
         socket
         |> put_flash(:info, "Track updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_track(socket, :new, track_params) do
    case Music.create_track(track_params) do
      {:ok, track} ->
        notify_parent({:saved, track})

        {:noreply,
         socket
         |> put_flash(:info, "Track created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
