class BleViewModel extends ChangeNotifier {
  final BleService _bleService;
  ConnectionStatus _status;
  
  ConnectionStatus get status => _status;
  
  Future<void> connectToDevice(String deviceId);
  Future<void> disconnect();
  void startScanning();
}