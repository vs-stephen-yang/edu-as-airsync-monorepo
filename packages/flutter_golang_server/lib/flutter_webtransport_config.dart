class FlutterWebtransportConfig {
  // Port for the configuration
  final int port;

  // Initial certificate as a byte array
  final List<String> cert;

  // Initial key as a byte array
  final List<String> key;

  // Initial read buffer size
  final int initReadBufferSize;

  // Maximum read buffer size
  final int maxReadBufferSize;

  final List<String> allowOrigins;

  // Constructor
  const FlutterWebtransportConfig(
      {this.port = 8443,
      this.cert = const [],
      this.key = const [],
      this.initReadBufferSize = 0,
      this.maxReadBufferSize = 0,
      this.allowOrigins = const []});

  // Factory constructor to create an instance from a Map
  factory FlutterWebtransportConfig.fromMap(Map<String, dynamic> map) {
    return FlutterWebtransportConfig(
        port: map['port'] as int,
        cert: map['cert'],
        key: map['key'],
        initReadBufferSize: map['initReadBufferSize'] as int,
        maxReadBufferSize: map['maxReadBufferSize'] as int,
        allowOrigins: map['allowOrigins']);
  }

  // Convert the instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'port': port,
      'cert': cert,
      'key': key,
      'initReadBufferSize': initReadBufferSize,
      'maxReadBufferSize': maxReadBufferSize,
      'allowOrigins': allowOrigins
    };
  }
}
