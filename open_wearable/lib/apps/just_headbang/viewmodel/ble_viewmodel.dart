import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/model/connection_status.dart';
import 'package:open_wearable/apps/just_headbang/services/ble_service.dart';

class BleViewModel extends ChangeNotifier {
  final BleService _bleService;
  ConnectionStatus _status;

  BleViewModel({required BleService bleService}) : _bleService = bleService, _status = ConnectionStatus.disconnected;
  
  ConnectionStatus get status => _status;
  
  Future<void> connectToDevice(String deviceId) {
    // TODO: implement connectToDevice
    throw UnimplementedError();
  }
  Future<void> disconnect() async {
    // TODO: implement disconnect
    throw UnimplementedError();
  }
  void startScanning() {
    // TODO: implement startScanning
  }
}