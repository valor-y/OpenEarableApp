class SensorViewModel extends ChangeNotifier {
  final SensorService _sensorService;
  SensorData? _latestData;
  List<SensorData> _dataBuffer = [];
  
  SensorData? get latestData => _latestData;
  List<SensorData> get dataBuffer => _dataBuffer;
  
  void startMonitoring();
  void stopMonitoring();
  void calibrate();
}