import 'package:open_wearable/apps/just_headbang/model/beat_detection.dart';

/// Model representing a music track
/// Includes metadata and beat information
/// Supports multiple music sources
/// Uses [MusicSourceType] to differentiate sources
/// Contains beat timestamps for gameplay synchronization
class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String albumArt;
  final List<BeatTimestamp> beats;
  
  final MusicSourceType sourceType;
  final String? filePath;      // for local files
  final String? spotifyUri;    // for Spotify
  
  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.albumArt = '',
    this.beats = const [],
    required this.sourceType,
    this.filePath,
    this.spotifyUri,
  });
}

enum MusicSourceType {
  local,
  spotify, //TODO: not fully implemented yet
  // appleMusic implement later
}
