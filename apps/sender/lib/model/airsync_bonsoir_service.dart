class AirSyncBonsoirService {
  final String uuid;
  final String name;
  final String type;
  final String displayCode;
  final String ip;
  final int port;

  AirSyncBonsoirService({
    required this.uuid,
    required this.name,
    required this.type,
    required this.displayCode,
    required this.ip,
    required this.port,
  });

  factory AirSyncBonsoirService.fromJson(Map<String, dynamic> json) {
    return AirSyncBonsoirService(
      uuid: json['name'],
      name: json['attributes']['fn'],
      type: json['type'],
      displayCode: json['attributes']['displayCode'],
      ip: json['attributes']['ip'],
      port: json['port'],
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
    };
  }
}
