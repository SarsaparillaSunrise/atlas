import { describe, it, expect, beforeEach, vi } from 'vitest';
import AudioPlayerService from './audio_player';

describe('AudioPlayerService', () => {
  let audioPlayerService;
  let mockAudioElement;
  let mockCallbacks;

  // Mock track data
  const mockTracks = [
    {
      id: 1,
      title: 'Track 1',
      artist_name: 'Artist 1',
      album_name: 'Album 1',
      audio_url: 'https://example.com/track1.mp3',
      art_url: 'https://example.com/art1.jpg',
      number: 1
    },
    {
      id: 2,
      title: 'Track 2',
      artist_name: 'Artist 2',
      album_name: 'Album 2',
      audio_url: 'https://example.com/track2.mp3',
      art_url: 'https://example.com/art2.jpg',
      number: 2
    },
    {
      id: 3,
      title: 'Track 3',
      artist_name: 'Artist 3',
      album_name: 'Album 3',
      audio_url: 'https://example.com/track3.mp3',
      art_url: 'https://example.com/art3.jpg',
      number: 3
    }
  ];

  beforeEach(() => {
    // Create a mock audio element
    mockAudioElement = {
      play: vi.fn(),
      pause: vi.fn(),
      addEventListener: vi.fn(),
      src: '',
      currentTime: 0,
      duration: 180,
      paused: true
    };

    // Create mock callbacks
    mockCallbacks = {
      onMetadataChange: vi.fn(),
      onTimeUpdate: vi.fn(),
      onPlaybackStateChange: vi.fn(),
      onTrackEnd: vi.fn()
    };

    // Mock MediaMetadata if it doesn't exist in the test environment
    if (!global.MediaMetadata) {
      global.MediaMetadata = vi.fn();
    }

    // Mock navigator.mediaSession if it doesn't exist
    if (!global.navigator) {
      global.navigator = {};
    }

    if (!navigator.mediaSession) {
      navigator.mediaSession = {
        metadata: null,
        playbackState: 'none',
        setActionHandler: vi.fn()
      };
    }

    // Create a new instance for each test
    audioPlayerService = new AudioPlayerService();
    audioPlayerService.initialize(mockAudioElement);
    audioPlayerService.setCallbacks(mockCallbacks);
  });

  describe('initialization', () => {
    it('initializes with empty playlist', () => {
      expect(audioPlayerService.playlist).toEqual([]);
      expect(audioPlayerService.position).toBe(0);
    });

    it('sets up event listeners during initialization', () => {
      expect(mockAudioElement.addEventListener).toHaveBeenCalledTimes(3);
    });

    it('stores provided callbacks', () => {
      expect(audioPlayerService.callbacks).toEqual(mockCallbacks);
    });
  });

  describe('playlist management', () => {
    it('loads a playlist and updates metadata', () => {
      const result = audioPlayerService.loadPlaylist(mockTracks);

      expect(result).toBe(true);
      expect(audioPlayerService.playlist).toEqual(mockTracks);
      expect(audioPlayerService.position).toBe(0);
      expect(mockCallbacks.onMetadataChange).toHaveBeenCalledWith(mockTracks[0]);
    });

    it('returns false when loading an empty playlist', () => {
      const result = audioPlayerService.loadPlaylist([]);

      expect(result).toBe(false);
      expect(audioPlayerService.playlist).toEqual([]);
    });

    it('returns the current track', () => {
      audioPlayerService.loadPlaylist(mockTracks);

      const currentTrack = audioPlayerService.getCurrentTrack();

      expect(currentTrack).toEqual(mockTracks[0]);
    });

    it('returns the next track in sequence', () => {
      audioPlayerService.loadPlaylist(mockTracks);

      const nextTrack = audioPlayerService.getNextTrack();

      expect(nextTrack).toEqual(mockTracks[1]);
    });

    it('loops back to first track when getting next at playlist end', () => {
      audioPlayerService.loadPlaylist(mockTracks);
      audioPlayerService.position = mockTracks.length - 1;

      const nextTrack = audioPlayerService.getNextTrack();

      expect(nextTrack).toEqual(mockTracks[0]);
    });
  });

  describe('playback control', () => {
    beforeEach(() => {
      audioPlayerService.loadPlaylist(mockTracks);
    });

    it('plays the current track and updates metadata', () => {
      const result = audioPlayerService.play();

      expect(result).toBe(true);
      expect(mockAudioElement.src).toBe(mockTracks[0].audio_url);
      expect(mockAudioElement.play).toHaveBeenCalled();
      expect(mockCallbacks.onMetadataChange).toHaveBeenCalledWith(mockTracks[0]);
    });

    it('fails to play when playlist is empty', () => {
      audioPlayerService.playlist = [];

      const result = audioPlayerService.play();

      expect(result).toBe(false);
      expect(mockAudioElement.play).not.toHaveBeenCalled();
    });

    it('plays when playPause is called while paused', () => {
      mockAudioElement.paused = true;

      audioPlayerService.playPause();

      expect(mockAudioElement.play).toHaveBeenCalled();
      expect(mockCallbacks.onPlaybackStateChange).toHaveBeenCalledWith('playing');
    });

    it('pauses when playPause is called while playing', () => {
      mockAudioElement.paused = false;

      audioPlayerService.playPause();

      expect(mockAudioElement.pause).toHaveBeenCalled();
      expect(mockCallbacks.onPlaybackStateChange).toHaveBeenCalledWith('paused');
    });

    it('advances to the next track in the playlist', () => {
      const result = audioPlayerService.playNext();

      expect(result).toBe(true);
      expect(audioPlayerService.position).toBe(1);
      expect(mockAudioElement.src).toBe(mockTracks[1].audio_url);
      expect(mockAudioElement.play).toHaveBeenCalled();
    });

    it('loops to first track when advancing past the end', () => {
      audioPlayerService.position = mockTracks.length - 1;

      const result = audioPlayerService.playNext();

      expect(result).toBe(true);
      expect(audioPlayerService.position).toBe(0);
      expect(mockAudioElement.src).toBe(mockTracks[0].audio_url);
    });

    it('goes to the previous track in the playlist', () => {
      audioPlayerService.position = 1;

      const result = audioPlayerService.playPrev();

      expect(result).toBe(true);
      expect(audioPlayerService.position).toBe(0);
      expect(mockAudioElement.src).toBe(mockTracks[0].audio_url);
    });

    it('loops to last track when going previous from the beginning', () => {
      audioPlayerService.position = 0;

      const result = audioPlayerService.playPrev();

      expect(result).toBe(true);
      expect(audioPlayerService.position).toBe(mockTracks.length - 1);
      expect(mockAudioElement.src).toBe(mockTracks[mockTracks.length - 1].audio_url);
    });

    it('plays a track by its track number', () => {
      const result = audioPlayerService.playTrack(2);

      expect(result).toBe(true);
      expect(audioPlayerService.position).toBe(1); // Second track (index 1)
      expect(mockAudioElement.src).toBe(mockTracks[1].audio_url);
    });

    it('fails when playing a non-existent track number', () => {
      const result = audioPlayerService.playTrack(99);

      expect(result).toBe(false);
    });

    it('changes the playback position to a specific time', () => {
      audioPlayerService.seek(30);

      expect(mockAudioElement.currentTime).toBe(30);
    });
  });

  describe('utility functions', () => {
    it('formats time in MM:SS format', () => {
      expect(audioPlayerService.formatTime(65)).toBe('01:05');
      expect(audioPlayerService.formatTime(3661)).toBe('61:01');
      expect(audioPlayerService.formatTime(0)).toBe('00:00');
    });
  });

  describe('event handling', () => {
    it('notifies time update listeners with current playback position', () => {
      const timeUpdateCall = mockAudioElement.addEventListener.mock.calls.find(
        call => call[0] === 'timeupdate'
      );

      if (timeUpdateCall) {
        const timeUpdateCallback = timeUpdateCall[1];
        timeUpdateCallback();

        expect(mockCallbacks.onTimeUpdate).toHaveBeenCalledWith(
          mockAudioElement.currentTime,
          mockAudioElement.duration
        );
      }
    });

    it('advances to next track when current track ends', () => {
      const endedCall = mockAudioElement.addEventListener.mock.calls.find(
        call => call[0] === 'ended'
      );

      if (endedCall) {
        audioPlayerService.loadPlaylist(mockTracks);
        vi.clearAllMocks(); // Clear previous calls

        const endedCallback = endedCall[1];
        endedCallback();

        expect(mockCallbacks.onTrackEnd).toHaveBeenCalled();
        expect(audioPlayerService.position).toBe(1); // Moved to next track
      }
    });
  });
});
