import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/model/player.dart';
import 'package:open_wearable/apps/just_headbang/services/scoring_service.dart';

/// Model representing a game session
/// Tracks score, combo, and hit history
/// Uses [MusicTrack] for the track being played
/// Uses [HitResult] for evaluating hits
/// Uses [ScoringService] for score calculations
/// Provides methods to update stats and calculate accuracy
class GameSession {
  final MusicTrack track;
  final Player player;
  int _score = 0;
  int _combo = 0;
  int _perfectHits = 0;
  int _goodHits = 0;
  int _missedBeats = 0;
  final ScoringService _scoringService = ScoringService();
  final List<HitResult> _hitHistory = [];

  GameSession({
    required this.track,
    required this.player,
  });

  /// Update session stats based on hit result
  void addHit(HitResult result) {
    _hitHistory.add(result);
    switch (result) {
      case HitResult.perfect:
        _perfectHits++;
        _combo++;
        _score += _scoringService.calculateScore(result, _combo, isPerfect: true);
        break;
      case HitResult.good:
        _goodHits++;
        _combo++;
        _score += _scoringService.calculateScore(result, _combo, isPerfect: false);
        break;
      case HitResult.miss:
        _missedBeats++;
        _combo = 0;
        break;
    }
  }

  /// Calculate accuracy as percentage of successful hits
  double getAccuracy() {
    final totalHits = _hitHistory.length;
    if (totalHits == 0) return 0.0;
    final successfulHits = _perfectHits + _goodHits;
    return (successfulHits / totalHits) * 100.0;
  }

  int get score => _score;
  int get combo => _combo;
  int get perfectHits => _perfectHits;
  int get goodHits => _goodHits;
  int get missedBeats => _missedBeats;
  List<HitResult> get hitHistory => _hitHistory;
}
