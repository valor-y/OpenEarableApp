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
  final List<BeatTimestamp> beats;
  
  final MusicSourceType sourceType;
  final String? assetPath;      // for bundled files
  final String? spotifyUri;    // for Spotify
  
  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.beats = const [],
    required this.sourceType,
    this.assetPath,
    this.spotifyUri,
  });
}

enum MusicSourceType {
  bundled,
  spotify, //TODO: not fully implemented yet
  // appleMusic implementation later
}

// Factory method to create a default track for testing
MusicTrack getDefaultTrack() {
  return MusicTrack(
    id: 'default',
    title: 'Sample Track',
    artist: 'Unknown Artist',
    duration: Duration.zero,
    sourceType: MusicSourceType.bundled,
    assetPath: 'assets/default_track.mp3',
  );
}
