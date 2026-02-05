import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/services/local_music_service.dart';
import 'package:open_wearable/apps/just_headbang/services/music_service.dart';

class MusicServiceFactory {
  static MusicService create(MusicSourceType type) {
    switch (type) {
      case MusicSourceType.local:
        return LocalMusicService();
      //TODO: add spotify service
      default:
        return LocalMusicService();
    }
  }
}