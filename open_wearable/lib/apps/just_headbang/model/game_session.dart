import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/services/scoring_service.dart';

/// Model representing a game session
/// Tracks score, combo, and hit history
/// Uses [MusicTrack] for the track being played
/// Uses [HitResult] for evaluating hits
/// Uses [ScoringService] for score calculations
/// Provides methods to update stats and calculate accuracy
class GameSession {
  final MusicTrack track;
  int score;
  int combo;
  int perfectHits;
  int goodHits;
  int missedBeats;
  List<HitResult> hitHistory;

  GameSession({
    required this.track,
    this.score = 0,
    this.combo = 0,
    this.perfectHits = 0,
    this.goodHits = 0,
    this.missedBeats = 0,
    List<HitResult>? hitHistory,
  }) : hitHistory = hitHistory ?? [];
  
  /// Update session stats based on hit result
  void addHit(HitResult result) {
    hitHistory.add(result);
    switch (result) {
      case HitResult.perfect:
        perfectHits++;
        combo++;
        break;
      case HitResult.good:
        goodHits++;
        combo++;
        break;
      case HitResult.miss:
        missedBeats++;
        combo = 0;
        break;
    }
  }

  /// Calculate accuracy as percentage of successful hits
  double getAccuracy() {
    final totalHits = hitHistory.length;
    if (totalHits == 0) return 0.0;
    final successfulHits = perfectHits + goodHits;
    return (successfulHits / totalHits) * 100.0;
  }
}
