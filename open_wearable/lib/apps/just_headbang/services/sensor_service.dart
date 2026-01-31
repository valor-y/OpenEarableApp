class SensorService {
  Stream<SensorData> get sensorStream;
  
  Future<void> startSensorReading();
  Future<void> stopSensorReading();
  void calibrate();
}