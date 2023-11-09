class TunnelMessage {
  final String action;
  final String connectionId;

  TunnelMessage(
    this.action,
    this.connectionId,
  );
  TunnelMessage.fromJson(Map<String, dynamic> json)
      : action = json['action'] as String,
        connectionId = json['connectionId'] as String;

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'connectionId': connectionId,
    };
  }
}

class TunnelClientConnected extends TunnelMessage {
  final String clientId;
  final String token;

  TunnelClientConnected(
    String connectionId,
    this.clientId,
    this.token,
  ) : super('connected', connectionId);

  TunnelClientConnected.fromJson(Map<String, dynamic> json)
      : clientId = json['clientId'] as String,
        token = json['token'] as String,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json.addAll({
      'clientId': clientId,
      'token': token,
    });

    return json;
  }
}

class TunnelClientDisconnected extends TunnelMessage {
  TunnelClientDisconnected(
    String connectionId,
  ) : super('disconnected', connectionId);

  TunnelClientDisconnected.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class DisconnectReason {
  int? code;
  String? text;

  DisconnectReason(
    this.code,
    this.text,
  );
}

class TunnelDisconnectClient extends TunnelMessage {
  DisconnectReason? reason;

  TunnelDisconnectClient(
    String connectionId,
    this.reason,
  ) : super('disconnect', connectionId);
}

class TunnelClientMsg extends TunnelMessage {
  Map<String, dynamic> data;

  TunnelClientMsg(
    String connectionId,
    this.data,
  ) : super('msg', connectionId);

  TunnelClientMsg.fromJson(Map<String, dynamic> json)
      : data = json['data'] as Map<String, dynamic>,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json.addAll({
      'data': data,
    });
    return json;
  }
}
