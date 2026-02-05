import 'package:flutter/foundation.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';

class SettingsViewModel extends ChangeNotifier {
  MusicSourceType _selectedMusicService = MusicSourceType.local;
  double _sensitivity = 0.5;

  Future<void> setMusicService(MusicSourceType type) async {
    _selectedMusicService = type;
    notifyListeners();
  }

  void setSensitivity(double value) {
    // TODO: implement setSensitivity
  }
  Future<void> requestPermissions() {
    // TODO: implement requestPermissions
    throw UnimplementedError();
  }
}
