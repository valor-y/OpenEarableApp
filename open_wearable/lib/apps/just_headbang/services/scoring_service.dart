class ScoringService {
  static const double PERFECT_WINDOW = 0.05;  // 50ms
  static const double GOOD_WINDOW = 0.15;     // 150ms
  
  HitResult evaluateHit(
    Duration beatTime, 
    Duration headbangTime, 
    double intensity
  );
  
  int calculateScore(HitResult result, int combo);
}
enum HitResult {
  perfect,
  good,
  miss
}