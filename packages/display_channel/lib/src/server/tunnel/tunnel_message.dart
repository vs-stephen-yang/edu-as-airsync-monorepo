class TunnelMessage {
  final String action;

  TunnelMessage(
    this.action,
  );
  TunnelMessage.fromJson(Map<String, dynamic> json)
      : action = json['action'] as String;

  Map<String, dynamic> toJson() {
    return {
      'action': action,
    };
  }
}

class TunnelClientEvent extends TunnelMessage {
  final String connectionId;

  TunnelClientEvent(
    String action,
    this.connectionId,
  ) : super(action);

  TunnelClientEvent.fromJson(Map<String, dynamic> json)
      : connectionId = json['connectionId'] as String,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'connectionId': connectionId,
    };
  }
}

class TunnelClientConnected extends TunnelClientEvent {
  final String clientId;
  final String token;
  final String displayCode;

  TunnelClientConnected(
    String connectionId,
    this.clientId,
    this.token,
    this.displayCode,
  ) : super('connected', connectionId);

  TunnelClientConnected.fromJson(Map<String, dynamic> json)
      : clientId = json['clientId'] as String,
        token = json['token'] as String,
        displayCode = json['displayCode'] as String,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json.addAll({
      'clientId': clientId,
      'token': token,
      'displayCode': displayCode,
    });

    return json;
  }
}

class TunnelClientDisconnected extends TunnelClientEvent {
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

class TunnelDisconnectClient extends TunnelClientEvent {
  DisconnectReason? reason;

  TunnelDisconnectClient(
    String connectionId,
    this.reason,
  ) : super('disconnect', connectionId);
}

class TunnelClientMsg extends TunnelClientEvent {
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

class TunnelHeartbeatMessage extends TunnelMessage {
  TunnelHeartbeatMessage() : super('heartbeat');

  TunnelHeartbeatMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}
