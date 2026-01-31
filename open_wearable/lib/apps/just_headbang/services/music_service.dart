abstract class MusicService {
  Future<List<MusicTrack>> getTracks();
  Future<void> play(MusicTrack track);
  Future<void> pause();
  Future<void> resume();
  Stream<Duration> get positionStream;
}