class MusicViewModel extends ChangeNotifier {
  final MusicService _musicService;
  MusicTrack? _currentTrack;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  
  MusicTrack? get currentTrack => _currentTrack;
  Duration get position => _position;
  bool get isPlaying => _isPlaying;
  
  Future<void> loadLibrary();
  Future<void> play(MusicTrack track);
  Future<void> togglePlayPause();
  Future<void> skip();
  Future<void> previous();
}