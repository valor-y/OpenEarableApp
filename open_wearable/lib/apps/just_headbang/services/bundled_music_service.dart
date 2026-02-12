import 'package:just_audio/just_audio.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/services/music_service.dart';
import 'package:open_wearable/models/logger.dart' as app_logger;

/// Service to handle local music playback using just_audio and on_audio_query
class BundledMusicService implements MusicService {
  final AudioPlayer _player = AudioPlayer();

  // The music tracks are hardcoded for now, but in a real implementation they could be loaded from a config file or discovered dynamically
  final List<MusicTrack> _tracks = [
    MusicTrack(
      id: 'b1',
      title: 'Antisocial',
      artist: 'Anthrax',
      duration: Duration(minutes: 4, seconds: 34),
      sourceType: MusicSourceType.bundled,
      assetPath: 'lib/apps/just_headbang/assets/music/Anthrax - Antisocial.mp3',
    ),
    MusicTrack(
      id: 'b2',
      title: 'The Watcher',
      artist: 'ARCH ENEMY',
      duration: Duration(minutes: 4, seconds: 58),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/ARCH ENEMY \u2013 The Watcher.mp3',
    ),
    MusicTrack(
      id: 'b3',
      title: 'Headbangeeeeerrrrr!!!!!!!',
      artist: 'BABYMETAL',
      duration: Duration(minutes: 4, seconds: 53),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/BABYMETAL - Headbangeeeeerrrrr!!!!!!!.mp3',
    ),
    MusicTrack(
      id: 'b4',
      title: 'Waking The Demon',
      artist: 'Bullet For My Valentine',
      duration: Duration(minutes: 4, seconds: 14),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/Bullet For My Valentine - Waking The Demon.mp3',
    ),
    MusicTrack(
      id: 'b5',
      title: 'Stranded',
      artist: 'Gojira',
      duration: Duration(minutes: 4, seconds: 32),
      sourceType: MusicSourceType.bundled,
      assetPath: 'lib/apps/just_headbang/assets/music/Gojira - Stranded.mp3',
    ),
    MusicTrack(
      id: 'b6',
      title: 'Break Stuff',
      artist: 'Limp Bizkit',
      duration: Duration(minutes: 2, seconds: 47),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/Limp Bizkit - Break Stuff.mp3',
    ),
    MusicTrack(
      id: 'b7',
      title: 'Symphony Of Destruction',
      artist: 'Megadeth',
      duration: Duration(minutes: 4, seconds: 18),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/Megadeth - Symphony Of Destruction.mp3',
    ),
    MusicTrack(
      id: 'b8',
      title: 'Master of Puppets',
      artist: 'Metallica',
      duration: Duration(minutes: 8, seconds: 35),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/Metallica - Master of Puppets.mp3',
    ),
    MusicTrack(
      id: 'b9',
      title: 'Domination',
      artist: 'Pantera',
      duration: Duration(minutes: 5, seconds: 10),
      sourceType: MusicSourceType.bundled,
      assetPath: 'lib/apps/just_headbang/assets/music/Pantera - Domination.mp3',
    ),
    MusicTrack(
      id: 'b10',
      title: 'The Greatest Fear',
      artist: 'Parkway Drive',
      duration: Duration(minutes: 5, seconds: 49),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/Parkway Drive - The Greatest Fear.mp3',
    ),
    MusicTrack(
      id: 'b11',
      title: 'Circle With Me',
      artist: 'Spiritbox',
      duration: Duration(minutes: 3, seconds: 53),
      sourceType: MusicSourceType.bundled,
      assetPath:
          'lib/apps/just_headbang/assets/music/Spiritbox - Circle With Me.mp3',
    ),
  ];

  @override
  Future<List<MusicTrack>> getTracks() async {
    app_logger.logger.i('Loading bundled music tracks');
    return _tracks;
  }

  @override
  Future<void> play(MusicTrack track) async {
    try {
      if (track.assetPath == null) {
        throw Exception('Track has no asset path');
      }

      app_logger.logger.i('Playing track: ${track.title}');
      await _player.setAsset(track.assetPath!);
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
    // just_audio bietet keine Audio-Daten für Visualisierung
    // TODO: separate Audio-Processing Library nutzen
    return null;
  }

  void dispose() {
    _player.dispose();
  }
}
