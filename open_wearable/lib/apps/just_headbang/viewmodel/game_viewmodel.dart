import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/model/beat_detection.dart';
import 'package:open_wearable/apps/just_headbang/model/game_session.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/model/sensor_data.dart';
import 'package:open_wearable/apps/just_headbang/services/beat_detection_service.dart';
import 'package:open_wearable/apps/just_headbang/services/scoring_service.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/music_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/sensor_viewmodel.dart';

class GameViewModel extends ChangeNotifier {
  final MusicViewModel _musicViewModel;
  final SensorViewModel _sensorViewModel;
  final BeatDetectionService _beatService;
  final ScoringService _scoringService;
  
  GameSession? _currentSession;
  List<BeatTimestamp> _upcomingBeats = [];

  GameViewModel(this._musicViewModel, this._sensorViewModel, this._beatService, this._scoringService);
  
  GameSession? get currentSession => _currentSession;
  
  /// Start a new game session with the given track
  Future<void> startGame(MusicTrack track) async {
    _currentSession = GameSession(track: track);
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
  void endGame() {
    //TODO store session results

    _currentSession = null;
    _upcomingBeats = [];
    notifyListeners();
  }
  void _checkBeatAlignment() {
    // Check if the latest headbang aligns with the next beat
    final headbangTime = _sensorViewModel.latestData?.timestamp;
    if (headbangTime == null || _upcomingBeats.isEmpty) return;

    final beat = _upcomingBeats.first;
    final timeDiff = headbangTime.difference(beat.timestamp as DateTime).inMilliseconds.abs();

    HitResult result;
    if (timeDiff <= 100) {
      result = HitResult.perfect;
    } else if (timeDiff <= 250) {
      result = HitResult.good;
    } else {
      result = HitResult.miss;
    }

    _currentSession?.addHit(result);
    _currentSession?.score += _scoringService.calculateScore(result, _currentSession!.combo);
    _upcomingBeats.removeAt(0);
    notifyListeners();
  }
  int get score => _currentSession?.score ?? 0;
  int get combo => _currentSession?.combo ?? 0;
}
