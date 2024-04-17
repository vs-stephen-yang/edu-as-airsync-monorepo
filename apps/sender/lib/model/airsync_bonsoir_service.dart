
class AirSyncBonsoirService {
  final String uuid;
  final String name;
  final String type;
  final String host;
  final String ip;
  final int port;

  AirSyncBonsoirService({
    required this.uuid,
    required this.name,
    required this.type,
    required this.host,
    required this.ip,
    required this.port,
  });

  factory AirSyncBonsoirService.fromJson(Map<String, dynamic> json) {
    return AirSyncBonsoirService(
      uuid: json['attributes']['uuid'],
      name: json['name'],
      type: json['type'],
      host: json['host'],
      ip: json['ip'],
      port: json['port'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'type': type,
      'domain': host,
      'ip': ip,
      'port': port,
    };
  }
}