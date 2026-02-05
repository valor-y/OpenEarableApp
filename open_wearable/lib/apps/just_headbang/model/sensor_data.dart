import 'package:open_wearable/apps/just_headbang/services/sensor_service.dart';

/// Model representing sensor data from wearable device
/// Includes accelerometer and gyroscope readings
/// Provides method to detect headbangs based on intensity threshold
/// Uses [Vector3] for 3D sensor data representation
/// Includes timestamp for synchronization
class SensorData {
  final DateTime timestamp;
  final Vector3 accelerometer;  // x, y, z
  final Vector3 gyroscope;      // x, y, z
  final double headbangIntensity;

  SensorData({required this.timestamp, required this.accelerometer, required this.gyroscope, required this.headbangIntensity});
  
  /// Determine if the sensor data indicates a headbang based on intensity threshold
  bool isHeadbang(double threshold) {
    return headbangIntensity >= threshold;
  }
}
