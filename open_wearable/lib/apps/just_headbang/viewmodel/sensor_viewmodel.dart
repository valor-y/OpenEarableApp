import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/just_headbang/model/sensor_data.dart';
import 'package:open_wearable/apps/just_headbang/services/sensor_service.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';

class SensorViewModel extends ChangeNotifier {
  final SensorService _sensorService;
  SensorData? _latestData;
  List<SensorData> _dataBuffer = [];
  StreamSubscription<IMUData>? _subscription;

  /// Calibration offsets (subtracted from raw readings)
  Vector3 _accelOffset = Vector3(x: 0, y: 0, z: 0);
  Vector3 _gyroOffset = Vector3(x: 0, y: 0, z: 0);

  static const int _maxBufferSize = 200;

  SensorViewModel(
      SensorManager wearable, SensorConfigurationProvider sensorConfigProvider,
      {required SensorService sensorService,})
      : _sensorService = sensorService;

  SensorData? get latestData => _latestData;
  List<SensorData> get dataBuffer => List.unmodifiable(_dataBuffer);

  void startMonitoring() {
    // Avoid duplicate subscriptions
    _subscription?.cancel();

    // Initialize the sensors, then listen to the IMU stream
    _sensorService.initializeSensors().then((_) {
      _subscription = _sensorService.imuStream.listen((imuData) {
        final accel = Vector3(
          x: (imuData.acceleration?.x ?? 0) - _accelOffset.x,
          y: (imuData.acceleration?.y ?? 0) - _accelOffset.y,
          z: (imuData.acceleration?.z ?? 0) - _accelOffset.z,
        );
        final gyro = Vector3(
          x: (imuData.rotation?.x ?? 0) - _gyroOffset.x,
          y: (imuData.rotation?.y ?? 0) - _gyroOffset.y,
          z: (imuData.rotation?.z ?? 0) - _gyroOffset.z,
        );

        final intensity = accel.magnitude + gyro.magnitude;

        final sensorData = SensorData(
          timestamp: imuData.timestamp,
          accelerometer: accel,
          gyroscope: gyro,
          headbangIntensity: intensity,
        );

        _latestData = sensorData;
        _dataBuffer.add(sensorData);
        if (_dataBuffer.length > _maxBufferSize) {
          _dataBuffer.removeAt(0);
        }

        notifyListeners();
      });
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    _sensorService.stopSensors();
  }

  /// Calibrates by capturing the current reading as the "zero" baseline.
  void calibrate() {
    final last = _sensorService.lastIMUData;
    if (last != null) {
      _accelOffset = last.acceleration ?? Vector3(x: 0, y: 0, z: 0);
      _gyroOffset = last.rotation ?? Vector3(x: 0, y: 0, z: 0);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
