defmodule AtlasWeb.TrackLiveTest do
  use AtlasWeb.ConnCase

  import Phoenix.LiveViewTest
  import Atlas.MusicFixtures

  @create_attrs %{title: "some title", number: 42, year: "some year", artist_id: 42, album_id: 42, artist_name: "some artist_name", album_name: "some album_name", audio_url: "some audio_url", art_url: "some art_url", duration: 42}
  @update_attrs %{title: "some updated title", number: 43, year: "some updated year", artist_id: 43, album_id: 43, artist_name: "some updated artist_name", album_name: "some updated album_name", audio_url: "some updated audio_url", art_url: "some updated art_url", duration: 43}
  @invalid_attrs %{title: nil, number: nil, year: nil, artist_id: nil, album_id: nil, artist_name: nil, album_name: nil, audio_url: nil, art_url: nil, duration: nil}

  defp create_track(_) do
    track = track_fixture()
    %{track: track}
  end

  describe "Index" do
    setup [:create_track]

    test "lists all tracks", %{conn: conn, track: track} do
      {:ok, _index_live, html} = live(conn, ~p"/tracks")

      assert html =~ "Listing Tracks"
      assert html =~ track.title
    end

    test "saves new track", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tracks")

      assert index_live |> element("a", "New Track") |> render_click() =~
               "New Track"

      assert_patch(index_live, ~p"/tracks/new")

      assert index_live
             |> form("#track-form", track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#track-form", track: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tracks")

      html = render(index_live)
      assert html =~ "Track created successfully"
      assert html =~ "some title"
    end

    test "updates track in listing", %{conn: conn, track: track} do
      {:ok, index_live, _html} = live(conn, ~p"/tracks")

      assert index_live |> element("#tracks-#{track.id} a", "Edit") |> render_click() =~
               "Edit Track"

      assert_patch(index_live, ~p"/tracks/#{track}/edit")

      assert index_live
             |> form("#track-form", track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#track-form", track: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tracks")

      html = render(index_live)
      assert html =~ "Track updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes track in listing", %{conn: conn, track: track} do
      {:ok, index_live, _html} = live(conn, ~p"/tracks")

      assert index_live |> element("#tracks-#{track.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tracks-#{track.id}")
    end
  end

  describe "Show" do
    setup [:create_track]

    test "displays track", %{conn: conn, track: track} do
      {:ok, _show_live, html} = live(conn, ~p"/tracks/#{track}")

      assert html =~ "Show Track"
      assert html =~ track.title
    end

    test "updates track within modal", %{conn: conn, track: track} do
      {:ok, show_live, _html} = live(conn, ~p"/tracks/#{track}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Track"

      assert_patch(show_live, ~p"/tracks/#{track}/show/edit")

      assert show_live
             |> form("#track-form", track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#track-form", track: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tracks/#{track}")

      html = render(show_live)
      assert html =~ "Track updated successfully"
      assert html =~ "some updated title"
    end
  end
end
