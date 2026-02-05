import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/services/music_service.dart';
import 'package:open_wearable/models/logger.dart' as app_logger;

/// Service to handle local music playback using just_audio and on_audio_query
class LocalMusicService implements MusicService {
  final AudioPlayer _player = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Future<List<MusicTrack>> getTracks() async {
    try {
      app_logger.logger.i('Loading local music tracks');
      final songs = await _audioQuery.querySongs(
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      app_logger.logger.i('Found ${songs.length} music tracks');

      return songs
          .map((song) => MusicTrack(
                id: song.id.toString(),
                title: song.title,
                artist: song.artist ?? 'Unknown',
                duration: Duration(milliseconds: song.duration ?? 0),
                sourceType: MusicSourceType.local,
                filePath: song.data,
              ))
          .toList();
    } catch (e) {
      app_logger.logger.e('Error loading music tracks: $e');
      return [];
    }
  }

  @override
  Future<void> play(MusicTrack track) async {
    try {
      if (track.filePath == null) {
        throw Exception('Track has no file path');
      }

      app_logger.logger.i('Playing track: ${track.title}');
      await _player.setFilePath(track.filePath!);
      await _player.play();
    } catch (e) {
      app_logger.logger.e('Error playing track: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      app_logger.logger.i('Pausing playback');
      await _player.pause();
    } catch (e) {
      app_logger.logger.e('Error pausing: $e');
      rethrow;
    }
  }

  @override
  Future<void> resume() async {
    try {
      app_logger.logger.i('Resuming playback');
      await _player.play();
    } catch (e) {
      app_logger.logger.e('Error resuming: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      app_logger.logger.i('Stopping playback');
      await _player.stop();
    } catch (e) {
      app_logger.logger.e('Error stopping: $e');
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      app_logger.logger.i('Seeking to $position');
      await _player.seek(position);
    } catch (e) {
      app_logger.logger.e('Error seeking: $e');
      rethrow;
    }
  }

  @override
  Stream<Duration> get positionStream {
    return _player.positionStream;
  }

  @override
  Stream<PlaybackState> get playbackStateStream {
    return _player.playerStateStream.map((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          return PlaybackState.idle;
        case ProcessingState.loading:
          return PlaybackState.loading;
        case ProcessingState.buffering:
          return PlaybackState.loading;
        case ProcessingState.ready:
          return state.playing ? PlaybackState.playing : PlaybackState.paused;
        case ProcessingState.completed:
          return PlaybackState.stopped;
      }
    });
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        throw Exception('Volume must be between 0.0 and 1.0');
      }
      await _player.setVolume(volume);
    } catch (e) {
      app_logger.logger.e('Error setting volume: $e');
      rethrow;
    }
  }

  @override
  Stream<List<double>>? getAudioDataStream() {
    // !just_audio bietet keine Audio-Daten für Visualisierung
    // TODO: separate Audio-Processing Library nutzen
    return null;
  }

  /// Cleanup
  void dispose() {
    _player.dispose();
  }
}
