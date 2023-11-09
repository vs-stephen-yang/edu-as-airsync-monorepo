enum ChannelMessageType {
  channelConnected,
  clientConnected,
  displayStatus,
  joinDisplay,
  startPresent,
  presentAccepted,
  presentRejected,
  stopPresent,
  presentSignal,
  presentChangeQuality,
  allowPresent,
  heartbeat,
  unknown,
}

final channelMessageActionNames = <int, String>{
  ChannelMessageType.channelConnected.index: 'channel-connected',
  ChannelMessageType.clientConnected.index: 'client-connected',
  ChannelMessageType.displayStatus.index: 'display-status',
  ChannelMessageType.joinDisplay.index: 'join-display',
  ChannelMessageType.startPresent.index: 'start-present',
  ChannelMessageType.presentAccepted.index: 'present-accepted',
  ChannelMessageType.presentRejected.index: 'present-rejected',
  ChannelMessageType.stopPresent.index: 'stop-present',
  ChannelMessageType.presentSignal.index: 'present-signal',
  ChannelMessageType.presentChangeQuality.index: 'present-change-quality',
  ChannelMessageType.allowPresent.index: 'allow-present',
  ChannelMessageType.heartbeat.index: 'heartbeat',
};

final channelMessageParsers = {
  ChannelMessageType.channelConnected.index: ChannelConnectedMessage.fromJson,
  ChannelMessageType.displayStatus.index: DisplayStatusMessage.fromJson,
  ChannelMessageType.joinDisplay.index: JoinDisplayMessage.fromJson,
  ChannelMessageType.startPresent.index: StartPresentMessage.fromJson,
  ChannelMessageType.presentAccepted.index: PresentAcceptedMessage.fromJson,
  ChannelMessageType.presentRejected.index: PresentRejectedMessage.fromJson,
  ChannelMessageType.stopPresent.index: StopPresentMessage.fromJson,
  ChannelMessageType.presentSignal.index: PresentSignalMessage.fromJson,
};

ChannelMessageType actionNameToChannelMessageType(String actionName) {
  int index = channelMessageActionNames.keys.firstWhere(
    (k) => channelMessageActionNames[k] == actionName,
    orElse: () => ChannelMessageType.unknown.index,
  );

  return ChannelMessageType.values[index];
}

abstract class ChannelMessage {
  ChannelMessageType messageType;
  int? seq; // the sequence number of the message

  bool get isControlMessage => false;

  ChannelMessage(this.messageType);

  ChannelMessage.fromJson(
    this.messageType,
    Map<String, dynamic> json,
  ) : seq = json['seq'] as int?;

  static ChannelMessage? parse(Map<String, dynamic> json) {
    final actionName = json['action'];

    ChannelMessageType messageType = actionNameToChannelMessageType(actionName);

    if (messageType == ChannelMessageType.unknown) {
      return null;
    }
    return channelMessageParsers[messageType.index]!(json);
  }

  Map<String, dynamic> _fromJson(Map<String, dynamic> json) => json['data'];

  Map<String, dynamic> toJson();

  Map<String, dynamic> _toJson(Map<String, dynamic> json) => {
        'action': channelMessageActionNames[messageType.index],
        'seq': seq,
        'data': json,
      };
}

class ChannelConnectedMessage extends ChannelMessage {
  int? heartbeatInterval; // in milliseconds
  String? reconnectionToken;

  // All messages before the ack, excluding the ack itself, have already been received.
  int? ack;

  @override
  bool get isControlMessage => true;

  ChannelConnectedMessage(
    this.heartbeatInterval,
    this.reconnectionToken,
  ) : super(ChannelMessageType.channelConnected);

  ChannelConnectedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.channelConnected, json) {
    final data = _fromJson(json);

    heartbeatInterval = data['heartbeatInterval'] as int?;
    reconnectionToken = data['reconnectionToken'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'heartbeatInterval': heartbeatInterval,
      'reconnectionToken': reconnectionToken,
    });
  }
}

class JoinDisplayMessage extends ChannelMessage {
  String? clientId;
  String? name;
  String? version;
  String? platform;

  JoinDisplayMessage(this.clientId) : super(ChannelMessageType.joinDisplay);

  JoinDisplayMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.joinDisplay, json) {
    final data = _fromJson(json);

    clientId = data['clientId'] as String?;
    name = data['name'] as String?;
    version = data['version'] as String?;
    platform = data['platform'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'clientId': clientId,
      'name': name,
      'version': version,
      'platform': platform,
    });
  }
}

class RtcIceServer {
  String? username;
  String? credential; //a password, key, or other secret.

  var urls = <String>[]; // an array or URLs: [ url1, ..., urlN ]

  RtcIceServer(this.urls);

  RtcIceServer.fromJson(Map<String, dynamic> json) {
    username = json['username'] as String?;
    credential = json['credential'] as String?;

    urls = json['urls'] as List<String>;
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'credential': credential,
      'urls': urls,
    };
  }
}

class DisplayConfiguration {
  final iceServers = <RtcIceServer>[];

  DisplayConfiguration();
  DisplayConfiguration.fromJson(Map<String, dynamic> json) {
    // iceServers
    if (json['iceServers'] != null) {
      for (var iceServer in json['iceServers'] as List) {
        iceServers.add(
          RtcIceServer.fromJson(iceServer),
        );
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'iceServers': iceServers
          .map(
            (iceServer) => iceServer.toJson(),
          )
          .toList(),
    };
  }
}

class DisplayStatus {
  bool? moderator;

  DisplayStatus();

  DisplayStatus.fromJson(Map<String, dynamic> json)
      : moderator = json['moderator'] as bool?;

  Map<String, dynamic> toJson() => {
        'moderator': moderator,
      };
}

class DisplayStatusMessage extends ChannelMessage {
  String? name;
  String? version;
  String? platform;
  DisplayConfiguration? configuration;
  DisplayStatus? status;

  DisplayStatusMessage() : super(ChannelMessageType.displayStatus);

  DisplayStatusMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.displayStatus, json) {
    final data = super._fromJson(json);

    name = data['name'] as String?;
    version = data['version'] as String?;
    platform = data['platform'] as String?;

    // configuration
    if (data['configuration'] != null) {
      configuration = DisplayConfiguration.fromJson(data['configuration']);
    }

    // status
    if (data['status'] != null) {
      status = DisplayStatus.fromJson(data['status']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'name': name,
      'version': version,
      'platform': platform,
      'configuration': configuration?.toJson(),
      'status': status?.toJson(),
    });
  }
}

class StartPresentMessage extends ChannelMessage {
  String? sessionId;

  StartPresentMessage(this.sessionId) : super(ChannelMessageType.startPresent);

  StartPresentMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.startPresent, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
    });
  }
}

class StopPresentMessage extends ChannelMessage {
  String? sessionId;

  StopPresentMessage() : super(ChannelMessageType.stopPresent);

  StopPresentMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.stopPresent, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
    });
  }
}

class AllowPresentMessage extends ChannelMessage {
  String? sessionId;

  AllowPresentMessage() : super(ChannelMessageType.allowPresent);

  AllowPresentMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.allowPresent, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
    });
  }
}

enum SignalMessageType {
  offer,
  answer,
  candidate,
}

SignalMessageType stringToSdpType(String str) {
  for (SignalMessageType t in SignalMessageType.values) {
    if (str == t.name) {
      return t;
    }
  }
  throw ArgumentError('Invalid SdpType string: $str');
}

class PresentSignalMessage extends ChannelMessage {
  String? sessionId;
  SignalMessageType? signalType;

  String? sdp;

  String? candidate;
  String? sdpMid;
  int? sdpMLineIndex;

  PresentSignalMessage(this.sessionId, this.signalType)
      : super(ChannelMessageType.presentSignal);

  PresentSignalMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.presentSignal, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;

    if (data['type'] != null) {
      signalType = stringToSdpType(data['type'] as String);
    }

    sdp = data['sdp'] as String?;
    candidate = data['candidate'] as String?;
    sdpMid = data['sdpMid'] as String?;
    sdpMLineIndex = data['sdpMLineIndex'] as int?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'type': signalType?.name,
      'sdp': sdp,
      'candidate': candidate,
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
    });
  }
}

class PresentAcceptedMessage extends ChannelMessage {
  String? sessionId;

  PresentAcceptedMessage(this.sessionId)
      : super(ChannelMessageType.presentAccepted);

  PresentAcceptedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.presentAccepted, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
    });
  }
}

class PresentRejectReason {
  int? code;
  String? text;

  PresentRejectReason(this.code, this.text);

  PresentRejectReason.fromJson(Map<String, dynamic> json)
      : code = json['code'] as int?,
        text = json['text'] as String?;

  Map<String, dynamic> toJson() => {
        'code': code,
        'text': text,
      };
}

class PresentRejectedMessage extends ChannelMessage {
  String? sessionId;
  PresentRejectReason? reason;

  PresentRejectedMessage() : super(ChannelMessageType.presentRejected);

  PresentRejectedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.presentRejected, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
    reason = PresentRejectReason.fromJson(data['reason']);
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'reason': reason?.toJson(),
    });
  }
}

class HeartbeatMessage extends ChannelMessage {
  // All messages before the ack, excluding the ack itself, have already been received.
  int? ack;

  @override
  bool get isControlMessage => true;

  HeartbeatMessage(this.ack) : super(ChannelMessageType.heartbeat);

  HeartbeatMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.heartbeat, json) {
    final data = super._fromJson(json);

    ack = data['ack'] as int?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'ack': ack,
    });
  }
}

class ClientConnectedMessage extends ChannelMessage {
  // All messages before the ack, excluding the ack itself, have already been received.
  int? ack;

  @override
  bool get isControlMessage => true;

  ClientConnectedMessage(this.ack) : super(ChannelMessageType.clientConnected);

  ClientConnectedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.clientConnected, json) {
    final data = super._fromJson(json);

    ack = data['ack'] as int?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'ack': ack,
    });
  }
}
