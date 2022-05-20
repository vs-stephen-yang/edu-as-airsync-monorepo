// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

class ModeratorPeerMessage {
  ModeratorPeerMessage({
    required this.messageFor,
    required this.action,
    required this.status,
    this.extra,
    required this.messageId,
    required this.nextId,
  });

  String messageFor;
  String action;
  String status;
  dynamic extra;
  String messageId;
  String nextId;

  factory ModeratorPeerMessage.fromRawJson(String str) =>
      ModeratorPeerMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ModeratorPeerMessage.fromJson(Map<String, dynamic> json) =>
      ModeratorPeerMessage(
        messageFor: json['messageFor'],
        action: json['action'],
        status: json['status'],
        extra: json['extra'],
        messageId: json['messageId'],
        nextId: json['nextId'],
      );

  Map<String, dynamic> toJson() => {
        'messageFor': messageFor,
        'action': action,
        'status': status,
        'extra': extra,
        'messageId': messageId,
        'nextId': nextId,
      };
}
