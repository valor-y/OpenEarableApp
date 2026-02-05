import 'dart:async';
import 'package:open_wearable/apps/just_headbang/model/beat_detection.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/models/logger.dart' as app_logger;

/// Service for detecting beats in music tracks
/// Uses simple energy-based detection for prototyping
/// Provides real-time beat stream for gameplay synchronization
/// Emits detected beats via StreamController
/// Handles different music sources via [MusicTrack]
class BeatDetectionService {
  final List<BeatTimestamp> _detectedBeats = [];
  final StreamController<BeatTimestamp> _beatController =
      StreamController<BeatTimestamp>.broadcast();

  /// Simplified beat detection based on energy peaks
  Future<List<BeatTimestamp>> detectBeats(MusicTrack track) async {
    try {
      app_logger.logger.i('Starting beat detection for: ${track.title}');

      _detectedBeats.clear();

      // Simulate beat detection with regular intervals
      // In a real implementation, audio data would be analyzed here
      final estimatedBPM = 120.0; // Standard BPM
      final beatInterval =
          Duration(milliseconds: (60000 / estimatedBPM).toInt());

      int beatCount = 0;
      Duration currentTime = Duration.zero;

      while (currentTime < track.duration) {
        final beat = BeatTimestamp(
          timestamp: currentTime,
          confidence:
              0.85 + (beatCount % 2) * 0.1, // Alternate between 0.85 and 0.95
          bpm: estimatedBPM,
        );

        _detectedBeats.add(beat);
        currentTime += beatInterval;
        beatCount++;
      }

      app_logger.logger.i(
        'Detected ${_detectedBeats.length} beats, '
        'BPM: $estimatedBPM, Duration: ${track.duration.inSeconds}s',
      );

      return _detectedBeats;
    } catch (e) {
      app_logger.logger.e('Error during beat detection: $e');
      return [];
    }
  }

  /// Simulate real-time beat detection
  Stream<BeatTimestamp> getRealTimeBeats() {
    return _beatController.stream;
  }

  /// Emit a beat (for testing/simulation)
  void emitBeat(BeatTimestamp beat) {
    _beatController.add(beat);
  }

  /// Cleanup
  void dispose() {
    _beatController.close();
  }
}
