/// Scoring service for evaluating headbang hits against music beats
class ScoringService {
  static const double perfectWindow = 0.05;  // 50ms
  static const double goodWindow = 0.15;     // 150ms
  
  /// Evaluate a headbang against a beat time
  HitResult evaluateHit(
    Duration beatTime, 
    Duration headbangTime, 
    double intensity,
  ) {
    final difference = (beatTime - headbangTime).inMilliseconds.abs() / 1000.0;
    
    if (difference <= perfectWindow && intensity >= 0.8) {
      return HitResult.perfect;
    } else if (difference <= goodWindow && intensity >= 0.5) {
      return HitResult.good;
    } else {
      return HitResult.miss;
    }
  }
  
  int calculateScore(HitResult result, int combo) {
    switch (result) {
      case HitResult.perfect:
        return 100 + (combo * 10);
      case HitResult.good:
        return 50 + (combo * 5);
      case HitResult.miss:
        return 0;
    }
  }
}
enum HitResult {
  perfect,
  good,
  miss
}