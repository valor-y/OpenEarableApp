import 'package:flutter/foundation.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/services/music_service.dart';
import 'package:open_wearable/apps/just_headbang/utils/music_service_factory.dart';

class MusicViewModel extends ChangeNotifier {
  MusicService _musicService;
  MusicSourceType _currentSource = MusicSourceType.local;
  MusicViewModel() : _musicService = MusicServiceFactory.create(MusicSourceType.local);
  MusicTrack? _currentTrack;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  
  MusicTrack? get currentTrack => _currentTrack;
  Duration get position => _position;
  bool get isPlaying => _isPlaying;
  
  void switchMusicSource(MusicSourceType newSource) {
    _currentSource = newSource;
    _musicService = MusicServiceFactory.create(newSource);
    notifyListeners();
  }
  
  Future<void> loadLibrary() async {
    // TODO: implement loadLibrary
  }
  Future<void> play(MusicTrack track) async {
    // TODO: implement play
  }
  Future<void> togglePlayPause() async {
    // TODO: implement togglePlayPause
  }
  Future<void> skip() async {
    // TODO: implement skip
  }
  Future<void> previous() async {
    // TODO: implement previous
  }
}