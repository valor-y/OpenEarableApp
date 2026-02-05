import 'dart:async';
import 'dart:math';
import 'package:open_earable_flutter/open_earable_flutter.dart' as open_earable;
import 'package:open_wearable/apps/just_headbang/services/ble_service.dart';
import 'package:open_wearable/models/logger.dart' as app_logger;

/// Service to handle sensor data from the wearable device
class SensorService {
  final BleService _bleService;

  // Stream Controller for IMU data
  final StreamController<IMUData> _imuController =
      StreamController<IMUData>.broadcast();

  // Stream Subscriptions
  StreamSubscription<open_earable.SensorValue>? _accelerometerSubscription;
  StreamSubscription<open_earable.SensorValue>? _gyroscopeSubscription;
  StreamSubscription<open_earable.SensorValue>? _magnetometerSubscription;

  // Cache for the latest values
  IMUData? _lastIMUData;

  Stream<IMUData> get imuStream => _imuController.stream;
  IMUData? get lastIMUData => _lastIMUData;

  SensorService(this._bleService);

  /// Initialize the sensor streams
  Future<void> initializeSensors() async {
    try {
      app_logger.logger.i('Initializing sensors');

      if (!_bleService.isConnected) {
        throw Exception('Device not connected');
      }

      final sensors = _bleService.getAvailableSensors();
      if (sensors.isEmpty) {
        throw Exception('No sensors available');
      }

      app_logger.logger.i('Available sensors: ${sensors.length}');
      for (var sensor in sensors) {
        app_logger.logger.d('Sensor: $sensor');
      }

      // Start IMU Streams (index-based fallback)
      _startAccelerometerStream(sensors);
      _startGyroscopeStream(sensors);
      _startMagnetometerStream(sensors);

      app_logger.logger.i('Sensors initialized successfully');
    } catch (e) {
      app_logger.logger.e('Failed to initialize sensors: $e');
      rethrow;
    }
  }

  /// Start Accelerometer Stream
  void _startAccelerometerStream(List<open_earable.Sensor> sensors) {
    try {
      final accelerometer = _pickSensor(sensors, 0, 'accelerometer');

      final accelerometerStream = _bleService.getSensorStream(accelerometer);
      _accelerometerSubscription = accelerometerStream.listen(
        (sensorValue) {
          _updateIMUData(
            acceleration: _parseSensorValue(sensorValue),
          );
          app_logger.logger.d('Accelerometer: $sensorValue');
        },
        onError: (e) {
          app_logger.logger.e('Accelerometer stream error: $e');
        },
      );
    } catch (e) {
      app_logger.logger.e('Failed to start accelerometer stream: $e');
    }
  }

  /// Start Gyroscope Stream
  void _startGyroscopeStream(List<open_earable.Sensor> sensors) {
    try {
      final gyroscope = _pickSensor(sensors, 1, 'gyroscope');

      _gyroscopeSubscription = _bleService.getSensorStream(gyroscope).listen(
        (sensorValue) {
          _updateIMUData(
            rotation: _parseSensorValue(sensorValue),
          );
          app_logger.logger.d('Gyroscope: $sensorValue');
        },
        onError: (e) => app_logger.logger.e('Gyroscope stream error: $e'),
      );

      app_logger.logger.i('Gyroscope stream started');
    } catch (e) {
      app_logger.logger.w('Gyroscope not available: $e');
    }
  }

  /// Start Magnetometer Stream
  void _startMagnetometerStream(List<open_earable.Sensor> sensors) {
    try {
      final magnetometer = _pickSensor(sensors, 2, 'magnetometer');

      _magnetometerSubscription =
          _bleService.getSensorStream(magnetometer).listen(
        (sensorValue) {
          app_logger.logger.d('Magnetometer: $sensorValue');
          _updateIMUData(
            magneticField: _parseSensorValue(sensorValue),
          );
        },
        onError: (e) => app_logger.logger.e('Magnetometer stream error: $e'),
      );

      app_logger.logger.i('Magnetometer stream started');
    } catch (e) {
      app_logger.logger.w('Magnetometer not available: $e');
    }
  }

  /// Helper: pick sensor by index (API has no sensorType)
  open_earable.Sensor _pickSensor(
    List<open_earable.Sensor> sensors,
    int index,
    String label,
  ) {
    if (sensors.length <= index) {
      throw Exception('No $label sensor at index $index');
    }
    return sensors[index];
  }

  /// Parses SensorValue into Vector3 format
  Vector3 _parseSensorValue(open_earable.SensorValue value) {
    try {
      final data = (value as dynamic).values as List<double>;
      return Vector3(
        x: (data[0] as num).toDouble(),
        y: (data[1] as num).toDouble(),
        z: (data[2] as num).toDouble(),
      );
    } catch (e) {
      app_logger.logger.e('Error parsing sensor value: $e');
      return Vector3(x: 0.0, y: 0.0, z: 0.0);
    }
  }

  /// Update IMU Data
  void _updateIMUData({
    Vector3? acceleration,
    Vector3? rotation,
    Vector3? magneticField,
  }) {
    _lastIMUData = IMUData(
      timestamp: DateTime.now(),
      acceleration: acceleration ?? _lastIMUData?.acceleration,
      rotation: rotation ?? _lastIMUData?.rotation,
      magneticField: magneticField ?? _lastIMUData?.magneticField,
    );

    _imuController.add(_lastIMUData!);
  }

  /// Stop all Sensor Streams
  Future<void> stopSensors() async {
    try {
      app_logger.logger.i('Stopping sensor streams');

      await _accelerometerSubscription?.cancel();
      await _gyroscopeSubscription?.cancel();
      await _magnetometerSubscription?.cancel();

      _accelerometerSubscription = null;
      _gyroscopeSubscription = null;
      _magnetometerSubscription = null;

      app_logger.logger.i('Sensor streams stopped');
    } catch (e) {
      app_logger.logger.e('Error stopping sensors: $e');
    }
  }

  /// Cleanup
  void dispose() {
    stopSensors();
    _imuController.close();
  }
}

/// IMU Data Model
class IMUData {
  final DateTime timestamp;
  final Vector3? acceleration;
  final Vector3? rotation;
  final Vector3? magneticField;

  IMUData({
    required this.timestamp,
    this.acceleration,
    this.rotation,
    this.magneticField,
  });

  @override
  String toString() =>
      'IMU(accel: $acceleration, gyro: $rotation, mag: $magneticField)';
}

/// Vector3 Model for 3-Axis Data
class Vector3 {
  final double x;
  final double y;
  final double z;

  Vector3({required this.x, required this.y, required this.z});

  /// Calculate the magnitude of the vector
  double get magnitude => sqrt(x * x + y * y + z * z);

  /// Normalize the vector
  Vector3 normalize() {
    final mag = magnitude;
    if (mag == 0) return Vector3(x: 0, y: 0, z: 0);
    return Vector3(
      x: x / mag,
      y: y / mag,
      z: z / mag,
    );
  }

  @override
  String toString() => 'Vector3(x: ${x.toStringAsFixed(2)}, '
      'y: ${y.toStringAsFixed(2)}, z: ${z.toStringAsFixed(2)})';
}
