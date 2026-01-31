class GameSession {
  final MusicTrack track;
  int score;
  int combo;
  int perfectHits;
  int goodHits;
  int missedBeats;
  List<HitResult> hitHistory;
  
  void addHit(HitResult result);
  double getAccuracy();
}