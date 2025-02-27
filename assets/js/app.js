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
import AudioPlayerService from "./services/audio_player";

const hooks = {};

hooks.playback = {
  mounted() {
    console.log("Mounted");
    
    const player = document.getElementById("audio-player");
    const audioService = new AudioPlayerService().initialize(player);
    
    // Set up UI callbacks
    audioService.setCallbacks({
      onMetadataChange: (track) => {
        document.getElementById("player-art").src = track.art_url;
        document.getElementById("player-title").innerHTML = track.title;
        document.getElementById("player-artist").innerHTML = track.artist_name;
      },
      onTimeUpdate: (currentTime, duration) => {
        const slider = document.getElementById("playback-slider");
        if (slider) {
          slider.max = duration;
          slider.value = currentTime;
        }
        
        document.getElementById("current-time").innerText = 
          audioService.formatTime(currentTime);
        document.getElementById("duration-time").innerText = 
          audioService.formatTime(duration);
      }
    });
    
    // Listen for slider changes to seek audio
    const slider = document.getElementById("playback-slider");
    slider.addEventListener("input", (event) => {
      audioService.seek(event.target.value);
    });
    
    // Handle LiveView events
    this.handleEvent("liveview_loaded", (payload) => {
      if (audioService.loadPlaylist(payload.playlist)) {
        document.getElementById("player").classList.remove("hidden");
      }
    });
    
    this.handleEvent("play_pause", (_) => {
      if (!audioService.getCurrentTrack()) {
        audioService.play();
      } else {
        audioService.playPause();
      }
    });
    
    this.handleEvent("play_prev", (_) => {
      audioService.playPrev();
    });
    
    this.handleEvent("play_next", (_) => {
      audioService.playNext();
    });
    
    this.handleEvent("play_song", (payload) => {
      audioService.playTrack(payload.track_number);
    });
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
