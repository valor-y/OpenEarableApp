import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/services/bundled_music_service.dart';
import 'package:open_wearable/apps/just_headbang/services/music_service.dart';

class MusicServiceFactory {
  static MusicService create(MusicSourceType type) {
    switch (type) {
      case MusicSourceType.bundled:
        return BundledMusicService();
      //TODO: add spotify service
      default:
        return BundledMusicService();
    }
  }
}
