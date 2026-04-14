enum ChannelMessageType {
  channelConnected,
  clientConnected,
  displayStatus,
  joinDisplay,
  startPresent,
  presentAccepted,
  presentRejected,
  stopPresent,
  pausePresent,
  resumePresent,
  presentSignal,
  changePresentQuality,
  allowPresent,
  heartbeat,
  channelClosed,
  startRemoteScreen,
  stopRemoteScreen,
  remoteScreenStatus,
  remoteScreenInfo,
  multicastInfo,
  joinDisplayRejected,
  remoteScreenSignal,
  inviteDisplayGroup,
  inviteDisplayGroupResult,
  inviteRemoteScreen,
  stopDisplayGroup,
  unknown,
}

enum JoinDisplayRejectedReasonCode {
  maxClientsReached(401),
  moderatorExited(402),
  receiverRemoteScreenBusy(403),
  joinedBeforeModeratorOn(404);

  const JoinDisplayRejectedReasonCode(this.code);
  final int code;
}

enum PresentRejectedReasonCode {
  timeout(400),
  maxPresentReached(401),
  authorizeTimeout(402),
  authorizeDecline(403);

  const PresentRejectedReasonCode(this.code);
  final int code;
}

enum StopPresentReasonCode {
  timeout(400),
  userTrigger(401),
  makeCallFailed(402),
  streamInterrupted(403),
  getStopPresentFromPeer(404),
  touchStopWhenTouchBack(405);

  const StopPresentReasonCode(this.code);
  final int code;
}

final channelMessageActionNames = <int, String>{
  ChannelMessageType.channelConnected.index: 'channel-connected',
  ChannelMessageType.clientConnected.index: 'client-connected',
  ChannelMessageType.displayStatus.index: 'display-status',
  ChannelMessageType.joinDisplay.index: 'join-display',
  ChannelMessageType.joinDisplayRejected.index: 'join-display-rejected',
  ChannelMessageType.startPresent.index: 'start-present',
  ChannelMessageType.presentAccepted.index: 'present-accepted',
  ChannelMessageType.presentRejected.index: 'present-rejected',
  ChannelMessageType.stopPresent.index: 'stop-present',
  ChannelMessageType.pausePresent.index: 'pause-present',
  ChannelMessageType.resumePresent.index: 'resume-present',
  ChannelMessageType.presentSignal.index: 'present-signal',
  ChannelMessageType.changePresentQuality.index: 'change-present-quality',
  ChannelMessageType.allowPresent.index: 'allow-present',
  ChannelMessageType.heartbeat.index: 'heartbeat',
  ChannelMessageType.channelClosed.index: 'channel-closed',
  ChannelMessageType.startRemoteScreen.index: 'start-remote-screen',
  ChannelMessageType.stopRemoteScreen.index: 'stop-remote-screen',
  ChannelMessageType.remoteScreenStatus.index: 'remote-screen-status',
  ChannelMessageType.remoteScreenInfo.index: 'remote-screen-info',
  ChannelMessageType.remoteScreenSignal.index: 'remote-screen-signal',
  ChannelMessageType.inviteDisplayGroup.index: 'invite-display-group',
  ChannelMessageType.inviteDisplayGroupResult.index:
      'invite-display-group-result',
  ChannelMessageType.inviteRemoteScreen.index: 'invite-remote-screen',
  ChannelMessageType.stopDisplayGroup.index: 'stop-display-group',
  ChannelMessageType.multicastInfo.index: 'multicast-info',
};

final channelMessageParsers = {
  ChannelMessageType.channelConnected.index: ChannelConnectedMessage.fromJson,
  ChannelMessageType.clientConnected.index: ClientConnectedMessage.fromJson,
  ChannelMessageType.displayStatus.index: DisplayStatusMessage.fromJson,
  ChannelMessageType.joinDisplay.index: JoinDisplayMessage.fromJson,
  ChannelMessageType.startPresent.index: StartPresentMessage.fromJson,
  ChannelMessageType.presentAccepted.index: PresentAcceptedMessage.fromJson,
  ChannelMessageType.presentRejected.index: PresentRejectedMessage.fromJson,
  ChannelMessageType.stopPresent.index: StopPresentMessage.fromJson,
  ChannelMessageType.pausePresent.index: PausePresentMessage.fromJson,
  ChannelMessageType.resumePresent.index: ResumePresentMessage.fromJson,
  ChannelMessageType.presentSignal.index: PresentSignalMessage.fromJson,
  ChannelMessageType.changePresentQuality.index: ChangePresentQuality.fromJson,
  ChannelMessageType.allowPresent.index: AllowPresentMessage.fromJson,
  ChannelMessageType.heartbeat.index: HeartbeatMessage.fromJson,
  ChannelMessageType.channelClosed.index: ChannelClosedMessage.fromJson,
  ChannelMessageType.startRemoteScreen.index: StartRemoteScreenMessage.fromJson,
  ChannelMessageType.stopRemoteScreen.index: StopRemoteScreenMessage.fromJson,
  ChannelMessageType.remoteScreenStatus.index:
      RemoteScreenStatusMessage.fromJson,
  ChannelMessageType.remoteScreenInfo.index: RemoteScreenInfoMessage.fromJson,
  ChannelMessageType.joinDisplayRejected.index:
      JoinDisplayRejectedMessage.fromJson,
  ChannelMessageType.remoteScreenSignal.index:
      RemoteScreenSignalMessage.fromJson,
  ChannelMessageType.inviteDisplayGroup.index:
      InviteDisplayGroupMessage.fromJson,
  ChannelMessageType.inviteDisplayGroupResult.index:
      InviteDisplayGroupResultMessage.fromJson,
  ChannelMessageType.inviteRemoteScreen.index:
      InviteRemoteScreenMessage.fromJson,
  ChannelMessageType.stopDisplayGroup.index: StopDisplayGroupMessage.fromJson,
  ChannelMessageType.multicastInfo.index: MulticastInfoMessage.fromJson,
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
        if (seq != null) 'seq': seq,
        'data': json,
      };
}

// https://socket.io/docs/v4/server-options/#pinginterval
// socket.io pingInterval
// The server sends a ping packet every pingInterval ms, and if the client does not answer with a pong within pingTimeout ms,
// the server considers that the connection is closed.
// Similarly, if the client does not receive a ping packet from the server within pingInterval + pingTimeout ms,
// then the client also considers that the connection is closed.

class ChannelConnectedMessage extends ChannelMessage {
  int? heartbeatInterval; // in milliseconds
  int? heartbeatTimeout; // in milliseconds
  String? reconnectionToken;

  // All messages before the ack, excluding the ack itself, have already been received.
  int? ack;

  @override
  bool get isControlMessage => true;

  ChannelConnectedMessage(
    this.heartbeatInterval, // in milliseconds
    this.heartbeatTimeout, // in milliseconds
    this.reconnectionToken,
    this.ack,
  ) : super(ChannelMessageType.channelConnected);

  ChannelConnectedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.channelConnected, json) {
    final data = _fromJson(json);

    heartbeatInterval = data['heartbeatInterval'] as int?;
    heartbeatTimeout = data['heartbeatTimeout'] as int?;
    reconnectionToken = data['reconnectionToken'] as String?;
    ack = data['ack'] as int?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'heartbeatInterval': heartbeatInterval,
      'heartbeatTimeout': heartbeatTimeout,
      'reconnectionToken': reconnectionToken,
      'ack': ack,
    });
  }
}

enum JoinIntentType {
  present,
  remoteScreen,
}

JoinIntentType stringToJoinIntentType(String str) {
  for (JoinIntentType t in JoinIntentType.values) {
    if (str == t.name) {
      return t;
    }
  }
  throw ArgumentError('Invalid JoinIntentType string: $str');
}

class JoinDisplayMessage extends ChannelMessage {
  String? clientId;
  String? userId;
  String? name;
  String? version;
  String? platform;
  JoinIntentType? intent;
  bool? isConnectedViaModeratorMode;

  JoinDisplayMessage(this.clientId) : super(ChannelMessageType.joinDisplay);

  JoinDisplayMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.joinDisplay, json) {
    final data = _fromJson(json);

    clientId = data['clientId'] as String?;
    userId = data['userId'] as String?;
    name = data['name'] as String?;
    version = data['version'] as String?;
    platform = data['platform'] as String?;

    if (data['intent'] != null) {
      intent = stringToJoinIntentType(data['intent'] as String);
    }

    isConnectedViaModeratorMode = data['isConnectedViaModeratorMode'] as bool?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'clientId': clientId,
      'userId': userId,
      'name': name,
      'version': version,
      'platform': platform,
      'intent': intent?.name,
      'isConnectedViaModeratorMode': isConnectedViaModeratorMode,
    });
  }
}

class JoinDisplayRejectedMessage extends ChannelMessage {
  Reason? reason;

  JoinDisplayRejectedMessage() : super(ChannelMessageType.joinDisplayRejected);

  JoinDisplayRejectedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.joinDisplayRejected, json) {
    final data = super._fromJson(json);

    if (data['reason'] != null) {
      reason = Reason.fromJson(data['reason']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'reason': reason?.toJson(),
    });
  }
}

class RtcIceServer {
  String? username;
  String? credential; //a password, key, or other secret.

  var urls = <String>[]; // an array or URLs: [ url1, ..., urlN ]

  RtcIceServer(
    this.urls, {
    this.username,
    this.credential,
  });

  RtcIceServer.fromJson(Map<String, dynamic> json) {
    username = json['username'] as String?;
    credential = json['credential'] as String?;

    urls = (json['urls'] as List<dynamic>)
        .map(
          (dynamic item) => item.toString(),
        )
        .toList();
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
  DisplayConfiguration();
  DisplayConfiguration.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    return {};
  }
}

class DisplayStatus {
  bool? moderator;
  bool? authorize;

  DisplayStatus();

  DisplayStatus.fromJson(Map<String, dynamic> json)
      : moderator = json['moderator'] as bool?,
        authorize = json['authorize'] as bool?;

  Map<String, dynamic> toJson() => {
        'moderator': moderator,
        'authorize': authorize,
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
  Reason? reason;

  StopPresentMessage() : super(ChannelMessageType.stopPresent);

  StopPresentMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.stopPresent, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
    if (data['reason'] != null) {
      reason = Reason.fromJson(data['reason']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'reason': reason?.toJson(),
    });
  }
}

class PausePresentMessage extends ChannelMessage {
  String? sessionId;

  PausePresentMessage(this.sessionId) : super(ChannelMessageType.pausePresent);

  PausePresentMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.pausePresent, json) {
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

class ResumePresentMessage extends ChannelMessage {
  String? sessionId;

  ResumePresentMessage(this.sessionId)
      : super(ChannelMessageType.resumePresent);

  ResumePresentMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.resumePresent, json) {
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
  final iceServers = <RtcIceServer>[];

  PresentAcceptedMessage(this.sessionId)
      : super(ChannelMessageType.presentAccepted);

  PresentAcceptedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.presentAccepted, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;

    // iceServers
    if (data['iceServers'] != null) {
      for (var iceServer in data['iceServers'] as List) {
        iceServers.add(
          RtcIceServer.fromJson(iceServer),
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'iceServers': iceServers
          .map(
            (iceServer) => iceServer.toJson(),
          )
          .toList(),
    });
  }
}

class Reason {
  int code;
  String? text;

  Reason(this.code, {this.text});

  Reason.fromJson(Map<String, dynamic> json)
      : code = json['code'] as int,
        text = json['text'] as String?;

  Map<String, dynamic> toJson() => {
        'code': code,
        'text': text,
      };
}

class PresentRejectedMessage extends ChannelMessage {
  String? sessionId;
  Reason? reason;

  PresentRejectedMessage() : super(ChannelMessageType.presentRejected);

  PresentRejectedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.presentRejected, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
    if (data['reason'] != null) {
      reason = Reason.fromJson(data['reason']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'reason': reason?.toJson(),
    });
  }
}

class PresentQualityConstraints {
  int? frameRate;
  int? width;
  int? height;
  int decodeHeightLimit;

  PresentQualityConstraints({
    this.frameRate,
    this.width,
    this.height,
    int? decodeHeightLimit,
  }) : decodeHeightLimit = decodeHeightLimit ?? 0;

  PresentQualityConstraints.fromJson(Map<String, dynamic> json)
      : frameRate = json['frameRate'] as int?,
        width = json['width'] as int?,
        height = json['height'] as int?,
        decodeHeightLimit = json['decodeHeightLimit'] as int? ?? 0;

  Map<String, dynamic> toJson() => {
        'frameRate': frameRate,
        'width': width,
        'height': height,
        'decodeHeightLimit': decodeHeightLimit,
      };
}

class ChangePresentQuality extends ChannelMessage {
  String? sessionId;
  PresentQualityConstraints? constraints;

  ChangePresentQuality(this.sessionId)
      : super(ChannelMessageType.changePresentQuality);

  ChangePresentQuality.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.changePresentQuality, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;

    if (data['constraints'] != null) {
      constraints = PresentQualityConstraints.fromJson(data['constraints']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'constraints': constraints?.toJson(),
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

class ChannelClosedMessage extends ChannelMessage {
  Reason? reason;

  @override
  bool get isControlMessage => true;

  ChannelClosedMessage(this.reason) : super(ChannelMessageType.channelClosed);

  ChannelClosedMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.channelClosed, json) {
    final data = super._fromJson(json);

    if (data['reason'] != null) {
      reason = Reason.fromJson(data['reason']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'reason': reason?.toJson(),
    });
  }
}

class StartRemoteScreenMessage extends ChannelMessage {
  String? sessionId;

  StartRemoteScreenMessage(this.sessionId)
      : super(ChannelMessageType.startRemoteScreen);

  StartRemoteScreenMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.startRemoteScreen, json) {
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

class StopRemoteScreenMessage extends ChannelMessage {
  String? sessionId;

  StopRemoteScreenMessage(this.sessionId)
      : super(ChannelMessageType.stopRemoteScreen);

  StopRemoteScreenMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.stopRemoteScreen, json) {
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

enum RemoteScreenStatus {
  accepted,
  rejected,
  kicked,
  fpsZero,
  hostFpsZero,
  hostRecreating,
  hostRecreateFailure,
  hostRecreateSuccess,
}

RemoteScreenStatus stringToRemoteScreenStatus(String str) {
  for (RemoteScreenStatus s in RemoteScreenStatus.values) {
    if (str == s.name) {
      return s;
    }
  }
  throw ArgumentError('Invalid RemoteScreenStatus string: $str');
}

class RemoteScreenStatusMessage extends ChannelMessage {
  String? sessionId;
  RemoteScreenStatus? status;

  RemoteScreenStatusMessage(
    this.sessionId,
    this.status,
  ) : super(ChannelMessageType.remoteScreenStatus);

  RemoteScreenStatusMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.remoteScreenStatus, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;

    if (data['status'] != null) {
      status = stringToRemoteScreenStatus(data['status'] as String);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'status': status?.name,
    });
  }
}

class IonSfuRoom {
  IonSfuRoom(
    this.url,
    this.roomId, {
    this.signalOverChannel = true,
    this.iceServers,
  });

  // TODO: Retain url for backward compatibility.
  // Plan to deprecate and remove in future versions.
  String? url;
  String? roomId;
  bool? signalOverChannel;
  List<RtcIceServer>? iceServers;

  String? get signalUrl {
    /// If `signalOverChannel` is true, returns `null` to indicate
    /// that the signaling is handled through the existing channel. Otherwise,
    /// it returns the value of `url` for backward compatibility.
    if (signalOverChannel != null && signalOverChannel!) {
      return null;
    }
    return url;
  }

  IonSfuRoom.fromJson(Map<String, dynamic> json)
      : url = json['url'] as String?,
        signalOverChannel = json['signalOverChannel'] as bool?,
        roomId = json['roomId'] as String? {
    // iceServers
    if (json['iceServers'] != null) {
      iceServers = <RtcIceServer>[];

      for (var iceServer in json['iceServers'] as List) {
        iceServers!.add(
          RtcIceServer.fromJson(iceServer),
        );
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'roomId': roomId,
        'signalOverChannel': signalOverChannel,
        if (iceServers != null)
          'iceServers': iceServers!
              .map(
                (iceServer) => iceServer.toJson(),
              )
              .toList(),
      };
}

class RemoteScreenInfoMessage extends ChannelMessage {
  String? sessionId;
  IonSfuRoom? ionSfuRoom;

  RemoteScreenInfoMessage(
    this.sessionId,
    this.ionSfuRoom,
  ) : super(ChannelMessageType.remoteScreenInfo);

  RemoteScreenInfoMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.remoteScreenInfo, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;

    if (data['ionSfuRoom'] != null) {
      ionSfuRoom = IonSfuRoom.fromJson(data['ionSfuRoom']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'ionSfuRoom': ionSfuRoom?.toJson(),
    });
  }
}

class RemoteScreenSignalMessage extends ChannelMessage {
  String? sessionId;
  String? signal;

  RemoteScreenSignalMessage(
    this.sessionId,
    this.signal,
  ) : super(ChannelMessageType.remoteScreenSignal);

  RemoteScreenSignalMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.remoteScreenSignal, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
    signal = data['signal'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'signal': signal,
    });
  }
}

class MulticastInfoMessage extends ChannelMessage {
  late String sessionId;
  late String ip;
  late int videoPort;
  late int audioPort;
  late int ssrc;
  late String keyHex;
  late String saltHex;
  late int videoRoc;
  late int audioRoc;

  MulticastInfoMessage(
    this.sessionId,
    this.ip,
    this.videoPort,
    this.audioPort,
    this.ssrc,
    this.keyHex,
    this.saltHex,
    this.videoRoc,
    this.audioRoc,
  ) : super(ChannelMessageType.multicastInfo);

  MulticastInfoMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.multicastInfo, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String;
    ip = data['ip'] as String;
    videoPort = data['videoPort'] as int;
    audioPort = data['audioPort'] as int;
    ssrc = data['ssrc'] as int;
    keyHex = data['keyHex'] as String;
    saltHex = data['saltHex'] as String;
    videoRoc = data['videoRoc'] as int;
    audioRoc = data['audioRoc'] as int;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'ip': ip,
      'videoPort': videoPort,
      'audioPort': audioPort,
      'ssrc': ssrc,
      'keyHex': keyHex,
      'saltHex': saltHex,
      'videoRoc': videoRoc,
      'audioRoc': audioRoc,
    });
  }
}

class InviteDisplayGroupMessage extends ChannelMessage {
  String? hostId;
  String? hostName;
  String? sessionId;
  String? displayCode;

  InviteDisplayGroupMessage({
    this.sessionId,
    this.displayCode,
    this.hostName,
  }) : super(ChannelMessageType.inviteDisplayGroup);

  InviteDisplayGroupMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.inviteDisplayGroup, json) {
    final data = super._fromJson(json);

    hostId = data['hostId'] as String?;
    hostName = data['hostName'] as String?;
    displayCode = data['displayCode'] as String?;
    sessionId = data['sessionId'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'hostId': hostId,
      'hostName': hostName,
      'displayCode': displayCode,
      'sessionId': sessionId,
    });
  }
}

class InviteDisplayGroupResultMessage extends ChannelMessage {
  String? status;

  InviteDisplayGroupResultMessage({
    this.status,
  }) : super(ChannelMessageType.inviteDisplayGroupResult);

  InviteDisplayGroupResultMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.inviteDisplayGroupResult, json) {
    final data = super._fromJson(json);

    status = data['status'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'status': status,
    });
  }
}

class InviteRemoteScreenMessage extends ChannelMessage {
  String? sessionId;

  InviteRemoteScreenMessage({
    this.sessionId,
  }) : super(ChannelMessageType.inviteRemoteScreen);

  InviteRemoteScreenMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.inviteRemoteScreen, json) {
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

class StopDisplayGroupMessage extends ChannelMessage {
  String? sessionId;
  String? reason;

  StopDisplayGroupMessage({
    this.sessionId,
  }) : super(ChannelMessageType.stopDisplayGroup);

  StopDisplayGroupMessage.fromJson(Map<String, dynamic> json)
      : super.fromJson(ChannelMessageType.stopDisplayGroup, json) {
    final data = super._fromJson(json);

    sessionId = data['sessionId'] as String?;
    reason = data['reason'] as String?;
  }

  @override
  Map<String, dynamic> toJson() {
    return super._toJson({
      'sessionId': sessionId,
      'reason': reason,
    });
  }
}
