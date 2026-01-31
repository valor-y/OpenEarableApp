class BeatDetectionService {
  Future<List<BeatTimestamp>> detectBeats(MusicTrack track);
  Stream<BeatTimestamp> getRealTimeBeats();
}