import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/just_headbang/model/connection_status.dart';
import 'package:open_wearable/models/logger.dart' as app_logger;

/// Service for managing BLE connections to OpenEarable devices
/// Handles scanning, connecting, disconnecting
/// Provides streams for connection status updates
/// Manages sensor data retrieval from connected devices
class BleService {
  final WearableManager _wearableManager = WearableManager();
  final StreamController<ConnectionStatus> _connectionController =
      StreamController<ConnectionStatus>.broadcast();

  Wearable? _connectedWearable;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;
  Wearable? get connectedWearable => _connectedWearable;
  bool get isConnected => _connectedWearable != null;

  /// Initializes the BLE service and ensures BLE is available
  Future<void> initialize() async {
    try {
      app_logger.logger.i('Initializing BLE Service');
      // Check if BLE is supported
      bool isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        throw Exception('BLE is not supported on this device');
      }
      _updateConnectionStatus(ConnectionStatus.ready);
    } catch (e) {
      app_logger.logger.e('Failed to initialize BLE Service: $e');
      _updateConnectionStatus(ConnectionStatus.error);
      rethrow;
    }
  }

  /// Connect to an OpenEarable device by device ID
  Future<void> connect(String deviceId) async {
    try {
      _updateConnectionStatus(ConnectionStatus.connecting);
      app_logger.logger.i('Connecting to device: $deviceId');

      // Nutze WearableManager um zu einem bekannten Gerät zu verbinden
      _connectedWearable = await _wearableManager.connectToDevice(
        DiscoveredDevice(
        id: deviceId,
        name: '',
        manufacturerData: Uint8List(0),
        serviceUuids: [],
        rssi: 0,
      ),
      );

      app_logger.logger.i('Connected to: ${_connectedWearable!.name}');

      // Register disconnect listener
      _connectedWearable!.addDisconnectListener(_onDeviceDisconnected);

      _updateConnectionStatus(ConnectionStatus.connected);
    } catch (e) {
      app_logger.logger.e('Connection failed: $e');
      _updateConnectionStatus(ConnectionStatus.error);
      _connectedWearable = null;
      rethrow;
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    try {
      if (_connectedWearable != null) {
        app_logger.logger.i('Disconnecting from: ${_connectedWearable!.name}');
        await _connectedWearable!.disconnect();
        _connectedWearable = null;
        _updateConnectionStatus(ConnectionStatus.disconnected);
      }
    } catch (e) {
      app_logger.logger.e('Disconnect failed: $e');
      _updateConnectionStatus(ConnectionStatus.error);
      rethrow;
    }
  }

  /// Scan for available OpenEarable devices
  Future<List<DiscoveredDevice>> scanDevices(
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      _updateConnectionStatus(ConnectionStatus.scanning);
      app_logger.logger.i('Starting BLE scan');

      final devices = <DiscoveredDevice>[];

      _scanSubscription = _wearableManager.scanStream.listen((device) {
        if (!devices.any((d) => d.id == device.id)) {
          devices.add(device);
          app_logger.logger.d('Discovered device: ${device.name} (${device.id})');
        }
      });

      // Start scan
      await _wearableManager.startScan();

      // Wait for timeout
      await Future.delayed(timeout);

      // Stop scan
      await stopScanning();

      app_logger.logger.i('Scan complete. Found ${devices.length} devices');
      _updateConnectionStatus(ConnectionStatus.ready);

      return devices;
    } catch (e) {
      app_logger.logger.e('Scan failed: $e');
      _updateConnectionStatus(ConnectionStatus.error);
      rethrow;
    }
  }

  /// Stop the current BLE scanning
  Future<void> stopScanning() async {
    try {
      await _wearableManager.stopScan();
      _scanSubscription?.cancel();
      _scanSubscription = null;
      app_logger.logger.i('Scan stopped');
    } catch (e) {
      app_logger.logger.e('Failed to stop scan: $e');
    }
  }

  /// Get sensor data from the connected device
  Stream<SensorValue> getSensorStream(Sensor sensor) {
    if (_connectedWearable == null) {
      throw Exception('No device connected');
    }
    return sensor.sensorStream;
  }

  /// Get available sensors from the connected device
  List<Sensor> getAvailableSensors() {
    // Check connection
    if (_connectedWearable == null) {
      throw Exception('No device connected');
    }
    // Check if device has SensorManager capability
    if (!_connectedWearable!.hasCapability<SensorManager>()) {
      return [];
    }
    // Return the list of sensors from SensorManager capability
    return _connectedWearable!.requireCapability<SensorManager>().sensors;
  }

  /// Get device information
  Map<String, String> getDeviceInfo() {
    if (_connectedWearable == null) {
      return {};
    }

    return {
      'name': _connectedWearable!.name,
      'id': _connectedWearable!.deviceId,
      'type': _connectedWearable!.runtimeType.toString(),
    };
  }

  /// Private Helper methods

  void _updateConnectionStatus(ConnectionStatus status) {
    app_logger.logger.d('Connection status changed to: $status');
    _connectionController.add(status);
  }

  void _onDeviceDisconnected() {
    app_logger.logger.i('Device disconnected');
    _connectedWearable = null;
    _updateConnectionStatus(ConnectionStatus.disconnected);
  }

  /// Cleanup
  void dispose() {
    _scanSubscription?.cancel();
    _connectionController.close();
  }
}

extension on WearableManager {
  Future<void> stopScan() async {}
}
