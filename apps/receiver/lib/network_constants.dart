/// Network-related constants shared across the application.
class NetworkConstants {
  // Private constructor to prevent instantiation
  NetworkConstants._();

  /// AirSync UDP discovery port
  static const int airSyncPort = 48469;

  /// AirSync UDP port range size (try port 48469 only)
  static const int airSyncPortRange = 1;

  /// AirSync UDP discovery message
  static const String airSyncMessage = 'airsync';
}
