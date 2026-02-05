/// Model representing a detected beat timestamp in a music track
/// Includes timestamp, confidence level, and optional BPM information
class BeatTimestamp {
  final Duration timestamp;
  final double confidence; // 0.0 - 1.0 indicating confidence of the beat detection
  final double? bpm; // Beats Per Minute

  BeatTimestamp({
    required this.timestamp,
    required this.confidence,
    this.bpm,
  });

  @override
  String toString() =>
      'BeatTimestamp(time: ${timestamp.inMilliseconds}ms, '
      'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
      'bpm: ${bpm?.toStringAsFixed(1) ?? "N/A"})';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeatTimestamp &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;
}
