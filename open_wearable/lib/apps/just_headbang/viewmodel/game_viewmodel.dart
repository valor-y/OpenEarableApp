import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/model/beat_detection.dart';
import 'package:open_wearable/apps/just_headbang/model/game_session.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/model/player.dart';
import 'package:open_wearable/apps/just_headbang/model/sensor_data.dart';
import 'package:open_wearable/apps/just_headbang/services/beat_detection_service.dart';
import 'package:open_wearable/apps/just_headbang/services/scoring_service.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/player_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/sensor_viewmodel.dart';

class GameViewModel extends ChangeNotifier {
  final SensorViewModel _sensorViewModel;
  final BeatDetectionService _beatService;

  GameSession? _currentSession;
  List<BeatTimestamp> _upcomingBeats = [];

  GameViewModel(this._sensorViewModel, this._beatService) {
    _currentSession = GameSession(
      track: getDefaultTrack(),
      player: defaultPlayer,
    );
  }

  GameSession? get currentSession => _currentSession;
  SensorViewModel get sensorViewModel => _sensorViewModel;
  BeatDetectionService get beatService => _beatService;

  /// Initialize a new game session with the given player
  void initSession(Player player) {
    _currentSession = GameSession(track: getDefaultTrack(), player: player);
    _upcomingBeats = [];
    notifyListeners();
  }

  /// Select a track for the current session
  void setSelectedTrack(MusicTrack track) {
    final currentPlayer = _currentSession?.player ?? defaultPlayer;
    _currentSession = GameSession(track: track, player: currentPlayer);
    notifyListeners();
  }

  /// Start a new game session
  Future<void> startGame() async {
    final currentPlayer = _currentSession?.player ?? defaultPlayer;
    _currentSession = GameSession(track: getDefaultTrack(), player: currentPlayer);
    _upcomingBeats = [];
    _beatService.getRealTimeBeats().listen((beat) {
      _upcomingBeats.add(beat);
    });
    notifyListeners();
    return;
  }

  void processHeadbang(SensorData data) {
    _checkBeatAlignment();
  }

  void endGame(PlayersViewModel playersViewModel) {
    if (_currentSession != null) {
      playersViewModel.updatePlayerSession(_currentSession!.score);
    }
    _currentSession = null;
    _upcomingBeats = [];
    notifyListeners();
  }

  void _checkBeatAlignment() {
    // Check if the latest headbang aligns with the next beat
    final headbangTime = _sensorViewModel.latestData?.timestamp;
    if (headbangTime == null || _upcomingBeats.isEmpty) return;

    final beat = _upcomingBeats.first;
    final timeDiff = headbangTime
        .difference(beat.timestamp as DateTime)
        .inMilliseconds
        .abs();

    HitResult result;
    if (timeDiff <= 100) {
      result = HitResult.perfect;
    } else if (timeDiff <= 250) {
      result = HitResult.good;
    } else {
      result = HitResult.miss;
    }

    _currentSession?.addHit(result);
    _upcomingBeats.removeAt(0);
    notifyListeners();
  }

  int get score => _currentSession?.score ?? 0;
  int get combo => _currentSession?.combo ?? 0;

  String? getCurrentPlayer() {
    return _currentSession?.player.name;
  }
}
