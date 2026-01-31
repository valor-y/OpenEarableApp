class GameViewModel extends ChangeNotifier {
  final MusicViewModel _musicViewModel;
  final SensorViewModel _sensorViewModel;
  final BeatDetectionService _beatService;
  final ScoringService _scoringService;
  
  GameSession? _currentSession;
  List<BeatTimestamp> _upcomingBeats = [];
  
  GameSession? get currentSession => _currentSession;
  
  Future<void> startGame(MusicTrack track);
  void processHeadbang(SensorData data);
  void endGame();
  void _checkBeatAlignment();
}
