import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:open_wearable/apps/just_headbang/model/game_session.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/services/music_service.dart';
import 'package:open_wearable/apps/just_headbang/utils/music_service_factory.dart';

class MusicViewModel extends ChangeNotifier {
  final MusicService _musicService;
  StreamSubscription<Duration>? _positionSubscription;
  late GameSession _currentSession;

  MusicViewModel()
      : _musicService = MusicServiceFactory.create(MusicSourceType.bundled) {
    _positionSubscription = _musicService.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
  }

  // Getter
  GameSession get currentSession => _currentSession;

  // Setter
  void setCurrentSession(GameSession session) {
    _currentSession = session;
    notifyListeners();
  }

  MusicTrack? _currentTrack;
  MusicTrack? _loadedTrack; // track already loaded into the player
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  MusicTrack? get currentTrack => _currentTrack;
  Duration get position => _position;
  bool get isPlaying => _isPlaying;

  /// Set the current track for playback.
  Future<void> setTrack(MusicTrack track) async {
    // Stop the currently playing track before switching
    if (_isPlaying) {
      await _musicService.stop();
      _isPlaying = false;
    }
    _currentTrack = track;
    _loadedTrack = null; // force reload when a new track is selected
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_currentTrack == null) return;

    if (_isPlaying) {
      // Update UI immediately, then do async work
      _isPlaying = false;
      notifyListeners();
      await _musicService.pause();
    } else {
      // Update UI immediately, then do async work
      _isPlaying = true;
      notifyListeners();
      try {
        if (_loadedTrack == _currentTrack) {
          await _musicService.resume();
        } else {
          await _musicService.play(_currentTrack!);
          _loadedTrack = _currentTrack;
        }
      } catch (e) {
        // Revert on failure
        _isPlaying = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _loadedTrack = null;
    notifyListeners();
    await _musicService.stop();
  }

  Future<List<MusicTrack>> getAvailableTracks() {
    return _musicService.getTracks();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
