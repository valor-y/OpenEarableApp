import 'package:flutter/foundation.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/just_headbang/model/sensor_data.dart';
import 'package:open_wearable/apps/just_headbang/services/sensor_service.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';

class SensorViewModel extends ChangeNotifier {
  final SensorService _sensorService;
  SensorData? _latestData;
  List<SensorData> _dataBuffer = [];

  SensorViewModel(SensorManager wearable, SensorConfigurationProvider sensorConfigProvider, {required SensorService sensorService}) : _sensorService = sensorService;
  
  SensorData? get latestData => _latestData;
  List<SensorData> get dataBuffer => _dataBuffer;
  
  void startMonitoring() {
    // TODO: implement startMonitoring
  }
  void stopMonitoring() {
    // TODO: implement stopMonitoring
  }
  void calibrate() {
    // TODO: implement calibrate
  }
}