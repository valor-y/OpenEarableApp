/// Model representing the connection status to the wearable device
/// Includes various states like [ready], [scanning], [connecting], [connected], [disconnected], and [error]
/// Provides extension methods for display names and connection checks
enum ConnectionStatus {
  ready,
  scanning,
  connecting,
  connected,
  disconnected,
  error,
}

extension ConnectionStatusExtension on ConnectionStatus {
  String get displayName {
    switch (this) {
      case ConnectionStatus.ready:
        return 'Ready';
      case ConnectionStatus.scanning:
        return 'Scanning...';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  bool get isConnected => this == ConnectionStatus.connected;
  bool get isConnecting => this == ConnectionStatus.connecting;
}
