import 'dart:async';
import 'dart:math';
import 'package:open_earable_flutter/open_earable_flutter.dart' as open_earable;
import 'package:open_wearable/models/logger.dart' as app_logger;
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';
import 'package:open_wearable/view_models/sensor_data_provider.dart';

/// Service to handle sensor data from the wearable device
class SensorService {
  final open_earable.SensorManager _sensorManager;
  final SensorConfigurationProvider _sensorConfigurationProvider;
  final Map<open_earable.Sensor, SensorDataProvider> _sensorDataProviders = {};
  final Map<open_earable.Sensor, void Function()> _providerListeners = {};

  // Stream Controller for IMU data
  final StreamController<IMUData> _imuController =
      StreamController<IMUData>.broadcast();

  // Cache for the latest values
  IMUData? _lastIMUData;

  Stream<IMUData> get imuStream => _imuController.stream;
  IMUData? get lastIMUData => _lastIMUData;

  SensorService(this._sensorManager, this._sensorConfigurationProvider);

  /// Initialize the sensor streams
  Future<void> initializeSensors() async {
    try {
      app_logger.logger.i('Initializing sensors');

      final sensors = _sensorManager.sensors;
      if (sensors.isEmpty) {
        throw Exception('No sensors available');
      }

      app_logger.logger.i('Available sensors: ${sensors.length}');
      for (var sensor in sensors) {
        app_logger.logger.d('Sensor: $sensor');
      }

      // Start IMU Streams (name-first, index fallback)
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
      final accelerometer = _findSensor(sensors, 0, 'accelerometer');
      _configureSensorForStreaming(accelerometer);
      _listenToSensor(
        accelerometer,
        onValue: (sensorValue) {
          _updateIMUData(
            acceleration: _parseSensorValue(sensorValue),
          );
          app_logger.logger.d('Accelerometer: $sensorValue');
        },
        label: 'Accelerometer',
      );
    } catch (e) {
      app_logger.logger.e('Failed to start accelerometer stream: $e');
    }
  }

  /// Start Gyroscope Stream
  void _startGyroscopeStream(List<open_earable.Sensor> sensors) {
    try {
      final gyroscope = _findSensor(sensors, 1, 'gyroscope');
      _configureSensorForStreaming(gyroscope);
      _listenToSensor(
        gyroscope,
        onValue: (sensorValue) {
          _updateIMUData(
            rotation: _parseSensorValue(sensorValue),
          );
          app_logger.logger.d('Gyroscope: $sensorValue');
        },
        label: 'Gyroscope',
      );
    } catch (e) {
      app_logger.logger.w('Gyroscope not available: $e');
    }
  }

  /// Start Magnetometer Stream
  void _startMagnetometerStream(List<open_earable.Sensor> sensors) {
    try {
      final magnetometer = _findSensor(sensors, 2, 'magnetometer');
      _configureSensorForStreaming(magnetometer);
      _listenToSensor(
        magnetometer,
        onValue: (sensorValue) {
          app_logger.logger.d('Magnetometer: $sensorValue');
          _updateIMUData(
            magneticField: _parseSensorValue(sensorValue),
          );
        },
        label: 'Magnetometer',
      );
    } catch (e) {
      app_logger.logger.w('Magnetometer not available: $e');
    }
  }

  open_earable.Sensor _findSensor(
    List<open_earable.Sensor> sensors,
    int index,
    String label,
  ) {
    final lowerLabel = label.toLowerCase();
    final byName = sensors.where(
      (s) => s.sensorName.toLowerCase() == lowerLabel,
    );
    if (byName.isNotEmpty) {
      return byName.first;
    }
    if (sensors.length <= index) {
      throw Exception('No $label sensor found');
    }
    return sensors[index];
  }

  void _configureSensorForStreaming(open_earable.Sensor sensor) {
    final Set<open_earable.SensorConfiguration> configurations =
        sensor.relatedConfigurations.toSet();

    for (final configuration in configurations) {
      if (configuration is open_earable.ConfigurableSensorConfiguration &&
          configuration.availableOptions
              .contains(open_earable.StreamSensorConfigOption())) {
        _sensorConfigurationProvider.addSensorConfigurationOption(
          configuration,
          open_earable.StreamSensorConfigOption(),
        );
      }

      final values = _sensorConfigurationProvider.getSensorConfigurationValues(
        configuration,
        distinct: true,
      );

      if (values.isEmpty) continue;

      _sensorConfigurationProvider.addSensorConfiguration(
        configuration,
        values.first,
      );
      configuration.setConfiguration(
        _sensorConfigurationProvider.getSelectedConfigurationValue(
          configuration,
        )!,
      );
    }
  }

  void _listenToSensor(
    open_earable.Sensor sensor, {
    required void Function(open_earable.SensorValue sensorValue) onValue,
    required String label,
  }) {
    final provider = _sensorDataProviders.putIfAbsent(
      sensor,
      () => SensorDataProvider(sensor: sensor),
    );

    void listener() {
      if (provider.sensorValues.isEmpty) return;
      final latestValue = provider.sensorValues.last;
      onValue(latestValue);
    }

    _providerListeners[sensor] = listener;
    provider.addListener(listener);
    app_logger.logger.i('$label stream started');
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

      for (final entry in _sensorDataProviders.entries) {
        final listener = _providerListeners[entry.key];
        if (listener != null) {
          entry.value.removeListener(listener);
        }
        entry.value.dispose();
      }
      _providerListeners.clear();
      _sensorDataProviders.clear();

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
