import 'package:open_wearable/apps/just_headbang/model/music_track.dart';

/// Service to handle music playback
abstract class MusicService {

  Future<List<MusicTrack>> getTracks();

  Future<void> play(MusicTrack track);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> seek(Duration position);

  Stream<Duration> get positionStream;

  Stream<PlaybackState> get playbackStateStream;

  Future<void> setVolume(double volume);

  /// Stream for audio data (for visualization)
  Stream<List<double>>? getAudioDataStream();
}

enum PlaybackState {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}
