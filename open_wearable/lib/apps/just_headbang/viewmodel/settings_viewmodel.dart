class SettingsViewModel extends ChangeNotifier {
  MusicServiceType _selectedMusicService;
  double _sensitivity;
  
  Future<void> setMusicService(MusicServiceType type);
  void setSensitivity(double value);
  Future<void> requestPermissions();
}