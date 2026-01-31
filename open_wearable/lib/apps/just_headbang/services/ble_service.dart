import 'package:open_wearable/apps/just_headbang/model/connection_status.dart';

class BleService {
  Stream<ConnectionStatus> get connectionStream;
  
  Future<void> initialize();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  List<BluetoothDevice> scanDevices();
}
