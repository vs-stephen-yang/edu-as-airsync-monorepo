enum DeviceSource {
  bonjour,
  udp,
  unknown,
}

extension DeviceSourceCodec on DeviceSource {
  String get value {
    switch (this) {
      case DeviceSource.bonjour:
        return 'bonjour';
      case DeviceSource.udp:
        return 'udp';
      case DeviceSource.unknown:
        return '';
    }
  }

  static DeviceSource fromValue(String? value) {
    switch (value) {
      case 'bonjour':
        return DeviceSource.bonjour;
      case 'udp':
        return DeviceSource.udp;
      default:
        return DeviceSource.unknown;
    }
  }
}

class AirSyncBonsoirService {
  final String uuid;
  final String name;
  final String type;
  final String displayCode;
  final String ip;
  final int port;
  final DeviceSource source;

  AirSyncBonsoirService({
    required this.uuid,
    required this.name,
    required this.type,
    required this.displayCode,
    required this.ip,
    required this.port,
    this.source = DeviceSource.unknown,
  });

  factory AirSyncBonsoirService.fromJson(Map<String, dynamic> json) {
    return AirSyncBonsoirService(
      uuid: json['name'],
      name: json['attributes']['fn'],
      type: json['type'],
      displayCode: json['attributes']['displayCode'],
      ip: json['attributes']['ip'],
      port: json['port'],
      source: DeviceSourceCodec.fromValue(json['source'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'type': type,
      'displayCode': displayCode,
      'ip': ip,
      'port': port,
      'source': source.value,
    };
  }
}
