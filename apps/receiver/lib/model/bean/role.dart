import 'dart:convert';

class Role {
  Role({
    required this.id,
  });

  String id;

  factory Role.fromRawJson(String str) => Role.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json['id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
      };
}
