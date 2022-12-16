import 'dart:convert';

class ModeratorRole {
  ModeratorRole({
    required this.id,
    required this.name,
    required this.remark,
    required this.status,
    this.extra,
  });

  String id;
  String name;
  String remark;
  String status;
  dynamic extra;

  factory ModeratorRole.fromRawJson(String str) =>
      ModeratorRole.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ModeratorRole.fromJson(Map<String, dynamic> json) => ModeratorRole(
        id: json['id'],
        name: json['action'],
        remark: json['remark'],
        status: json['status'],
        extra: json['extra'],
      );

  factory ModeratorRole.create(id) => ModeratorRole(
      id: id, name: 'name', remark: 'remark', status: 'sss', extra: {});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'remark': remark,
        'status': status,
        'extra': extra,
      };
}
