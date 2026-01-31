class SensorData {
  final DateTime timestamp;
  final Vector3 accelerometer;  // x, y, z
  final Vector3 gyroscope;      // x, y, z
  final double headbangIntensity;
  
  bool isHeadbang(double threshold);
}