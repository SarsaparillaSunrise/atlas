// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const hooks = {};

hooks.playback = {
  mounted() {
    console.log("Mounted");

    let playlist = [];
    let position = 0;
    const player = document.getElementById("audio-player");

    const updateMetadata = (track) => {
      navigator.mediaSession.metadata = new MediaMetadata({
        title: track.title,
        artist: track.artist_name,
        album: track.album_name,
        artwork: [
          {
            src: track.art_url,
            type: "image/jpeg",
          },
        ],
      });

      document.getElementById("player-art").src = track.art_url;
      document.getElementById("player-title").innerHTML = track.title;
      document.getElementById("player-artist").innerHTML = track.artist_name;
    };

    const getNextUp = () => {
      return position + 1 <= playlist.length - 1
        ? playlist[position + 1]
        : playlist[0];
    };

    const play = () => {
      // Call this only when a new song is playing
      player.pause();
      player.currentTime = 0;
      const track = playlist[position];
      player.src = track.audio_url;
      player.play();
      navigator.mediaSession.playbackState = "playing";
      updateMetadata(track);
      player.removeEventListener("ended", playNext);
      player.addEventListener("ended", playNext);
    };

    player.addEventListener("timeupdate", () => {
      const currentTime = player.currentTime;
      const duration = player.duration;
      const slider = document.getElementById("playback-slider");

      if (slider) {
        slider.max = duration;
        slider.value = currentTime;
      }

      document.getElementById("current-time").innerText =
        formatTime(currentTime);
      document.getElementById("duration-time").innerText = formatTime(duration);
    });

    // Listen for slider changes to seek audio
    const slider = document.getElementById("playback-slider");
    slider.addEventListener("input", (event) => {
      player.currentTime = event.target.value;
    });

    const formatTime = (seconds) => {
      const minutes = Math.floor(seconds / 60);
      const secondsLeft = Math.floor(seconds % 60);
      return `${String(minutes).padStart(2, "0")}:${String(
        secondsLeft
      ).padStart(2, "0")}`;
    };

    const playNext = () => {
      position + 1 <= playlist.length - 1 ? (position += 1) : (position = 0);
      play();
    };

    const playPrev = () => {
      position - 1 >= 0 ? (position -= 1) : (position = playlist.length - 1);
      play();
    };

    const playPause = () => {
      if (navigator.mediaSession.playbackState !== "playing") {
        player.play();
        navigator.mediaSession.playbackState = "playing";
      } else {
        player.pause();
        navigator.mediaSession.playbackState = "paused";
      }
    };

    const playTrack = (trackNumber) => {
      const index = playlist.findIndex(
        (track) => track.number === Number.parseInt(trackNumber, 10)
      );
      if (index !== -1) {
        position = index;
        play();
      } else {
        console.error(`Track number ${trackNumber} not found.`);
      }
    };

    this.handleEvent("liveview_loaded", (payload) => {
      playlist = payload.playlist;
      if (playlist.length > 0) {
        position = 0;
        updateMetadata(playlist[position]);
        document.getElementById("player").classList.remove("hidden");
      }
    });

    this.handleEvent("play_pause", (_) => {
      navigator.mediaSession.playbackState === "none" ? play() : playPause();
    });

    this.handleEvent("play_prev", (_) => {
      playPrev();
    });

    this.handleEvent("play_next", (_) => {
      playNext();
    });

    this.handleEvent("play_song", (payload) => {
      playTrack(payload.track_number);
    });

    navigator.mediaSession.setActionHandler("play", playPause);
    navigator.mediaSession.setActionHandler("pause", playPause);
    navigator.mediaSession.setActionHandler("previoustrack", playPrev);
    navigator.mediaSession.setActionHandler("nexttrack", playNext);
  },
};

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
