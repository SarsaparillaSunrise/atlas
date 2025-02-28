export default class AudioPlayerService {
  constructor() {
    this.playlist = [];
    this.position = 0;
    this.player = null;
    this.callbacks = {
      onMetadataChange: () => {},
      onTimeUpdate: () => {},
      onPlaybackStateChange: () => {},
      onTrackEnd: () => {},
    };
  }

  initialize(audioElement) {
    this.player = audioElement;
    this._setupEventListeners();
    return this;
  }

  setCallbacks(callbacks) {
    this.callbacks = { ...this.callbacks, ...callbacks };
    return this;
  }

  loadPlaylist(tracks) {
    this.playlist = tracks;
    this.position = 0;
    if (this.playlist.length > 0) {
      this._updateMetadata(this.playlist[this.position]);
    }
    return this.playlist.length > 0;
  }

  getCurrentTrack() {
    return this.playlist.length > 0 ? this.playlist[this.position] : null;
  }

  getNextTrack() {
    return this.position + 1 <= this.playlist.length - 1
      ? this.playlist[this.position + 1]
      : this.playlist[0];
  }

  play() {
    if (!this.playlist.length) return false;

    const track = this.playlist[this.position];
    this.player.pause();
    this.player.currentTime = 0;
    this.player.src = track.audio_url;
    this.player.play();
    this._updateMediaSession('playing');
    this._updateMetadata(track);
    return true;
  }

  playPause() {
    if (this.player.paused) {
      this.player.play();
      this._updateMediaSession('playing');
      this.callbacks.onPlaybackStateChange('playing');
    } else {
      this.player.pause();
      this._updateMediaSession('paused');
      this.callbacks.onPlaybackStateChange('paused');
    }
  }

  playNext() {
    this.position + 1 <= this.playlist.length - 1
      ? this.position += 1
      : this.position = 0;
    return this.play();
  }

  playPrev() {
    this.position - 1 >= 0
      ? this.position -= 1
      : this.position = this.playlist.length - 1;
    return this.play();
  }

  playTrack(trackNumber) {
    const index = this.playlist.findIndex(
      (track) => track.number === Number.parseInt(trackNumber, 10)
    );
    if (index !== -1) {
      this.position = index;
      return this.play();
    } else {
      console.error(`Track number ${trackNumber} not found.`);
      return false;
    }
  }

  seek(time) {
    if (this.player) {
      this.player.currentTime = time;
    }
  }

  formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secondsLeft = Math.floor(seconds % 60);
    return `${String(minutes).padStart(2, "0")}:${String(
      secondsLeft
    ).padStart(2, "0")}`;
  }

  _setupEventListeners() {
    if (!this.player) return;

    this.player.addEventListener("timeupdate", () => {
      const currentTime = this.player.currentTime;
      const duration = this.player.duration;
      this.callbacks.onTimeUpdate(currentTime, duration);
    });

    this.player.addEventListener("ended", () => {
      this.callbacks.onTrackEnd();
      this.playNext();
    });

    this.player.addEventListener("playing", () => {
      this._setupMediaSessionHandlers();
    });
  }

  _setupMediaSessionHandlers() {
    if ('mediaSession' in navigator) {
      navigator.mediaSession.setActionHandler("play", () => this.playPause());
      navigator.mediaSession.setActionHandler("pause", () => this.playPause());
      navigator.mediaSession.setActionHandler("previoustrack", () => this.playPrev());
      navigator.mediaSession.setActionHandler("nexttrack", () => this.playNext());
    }
  }

  _updateMetadata(track) {
    if ('mediaSession' in navigator) {
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
    }
    this.callbacks.onMetadataChange(track);
  }

  _updateMediaSession(state) {
    if ('mediaSession' in navigator) {
      navigator.mediaSession.playbackState = state;
    }
    this.callbacks.onPlaybackStateChange(state);
  }

  _getPlaybackState() {
    return 'mediaSession' in navigator ?
      navigator.mediaSession.playbackState :
      (this.player && !this.player.paused ? 'playing' : 'paused');
  }
}
