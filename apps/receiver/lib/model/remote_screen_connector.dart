import 'dart:async';

import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/multicast_info.dart';
import 'package:display_flutter/utility/cast_to_boards_session_logger.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_golang_server/flutter_ion_sfu_listener.dart';

enum RemotePresentationState {
  stopStreaming,
  waitForStream,
  streaming,
}

abstract class RemoteScreenConnector {
  Channel channel;
  RemotePresentationState remotePresentationState =
      RemotePresentationState.stopStreaming;
  String? _sessionId;

  String? get sessionId => _sessionId;
  String? clientId;
  String? senderName;
  String? senderVersion;
  String? senderPlatform;
  bool isDeleted = false;
  bool isTouchEnabled = false;

  /// 物件產生時間（本機時間）
  final DateTime createdAt;

  String get senderNameWithEllipsis {
    String result = senderName ?? '';
    if (result.length > 10) {
      result = '${result.substring(0, 10)}..';
    }
    return result;
  }

  Function()? onDisconnect;

  RemoteScreenConnector(
    this.channel,
    JoinDisplayMessage message,
  ) : createdAt = DateTime.now() {
    clientId = message.clientId;
    senderName = message.name;
    senderVersion = message.version;
    senderPlatform = message.platform;

    channel.stateStream.listen((ChannelState state) async {
      await _onChannelState(state);
    });
  }

  void processSignalFromPeer(String message);

  Future<void> _onChannelState(ChannelState state) async {
    switch (state) {
      case ChannelState.initialized:
        break;
      case ChannelState.connecting:
        break;
      case ChannelState.connected:
        break;
      case ChannelState.closed:
        await onDisconnect?.call();
        break;
    }
  }

  sendRemoteScreenState(RemoteScreenStatus status) {
    final remoteStatusMsg = RemoteScreenStatusMessage(_sessionId, status);
    channel.send(remoteStatusMsg);
  }
}

class RtcScreenConnector extends RemoteScreenConnector {
  String roomId;
  String? host;
  int port;

  Function(String message)? _signalHandler;
  final Completer _signalHandlerCompleter = Completer();

  RtcScreenConnector(
    Channel channel,
    this.roomId,
    this.host,
    this.port,
    JoinDisplayMessage message,
  ) : super(channel, message);

  onStartRemoteScreen(
    StartRemoteScreenMessage message,
    List<RtcIceServer>? iceServers,
  ) async {
    _sessionId = message.sessionId;
    log.info(
        'RtcScreenConnector: Received StartRemoteScreen, sessionId=$_sessionId');
    // accept
    log.info(
        'RtcScreenConnector: Sending accepted status, sessionId=$_sessionId');
    sendRemoteScreenState(RemoteScreenStatus.accepted);
    remotePresentationState = RemotePresentationState.waitForStream;
    // info
    final remoteScreenInfoMessage = RemoteScreenInfoMessage(
      _sessionId,
      IonSfuRoom(
        "ws://$host:$port/ws",
        roomId,
        iceServers: iceServers,
      ),
    );
    await _signalHandlerCompleter.future;
    log.info(
        'RtcScreenConnector: Sending RemoteScreenInfo, roomId=$roomId, host=$host:$port, sessionId=$_sessionId');
    channel.send(remoteScreenInfoMessage);
    remotePresentationState = RemotePresentationState.streaming;
  }

  void registerSignalHandler(Function(String message)? handler) {
    _signalHandler = handler;
    if (!_signalHandlerCompleter.isCompleted) {
      log.info(
          'RtcScreenConnector: Signal handler registered, sessionId=$_sessionId');
      _signalHandlerCompleter.complete();
    }
  }

  @override
  void processSignalFromPeer(String message) {
    _signalHandler?.call(message);
  }

  // send signal message to the peer
  void sendSignalToPeer(String message) {
    channel.send(
      RemoteScreenSignalMessage(_sessionId, message),
    );
  }

  void onRtcConnectionState(IceConnectionState state) {
    log.info(
        'RtcScreenConnector: ICE connection state=${state.name}, sessionId=$_sessionId');
    if (state == IceConnectionState.ICEConnectionStateFailed ||
        state == IceConnectionState.ICEConnectionStateClosed) {
      if (state == IceConnectionState.ICEConnectionStateFailed) {
        unawaited(castToBoardsSessionLogger
            .upload('ICE connection ${state.name}: sessionId=$_sessionId'));
      }
      remotePresentationState = RemotePresentationState.stopStreaming;
      onDisconnect?.call();
    }
  }
}

class MulticastScreenConnector extends RemoteScreenConnector {
  MulticastScreenConnector(super.channel, super.message);

  void onStartRemoteScreen(
      StartRemoteScreenMessage message, MulticastInfo streamInfo) {
    _sessionId = message.sessionId;
    // accept
    sendRemoteScreenState(RemoteScreenStatus.accepted);
    remotePresentationState = RemotePresentationState.waitForStream;

    // info
    final multicastInfoMessage = MulticastInfoMessage(
      _sessionId!,
      streamInfo.ip,
      streamInfo.videoPort,
      streamInfo.audioPort,
      streamInfo.ssrc,
      streamInfo.keyHex,
      streamInfo.saltHex,
      streamInfo.videoRoc,
      streamInfo.audioRoc,
    );

    channel.send(multicastInfoMessage);
    remotePresentationState = RemotePresentationState.streaming;
  }

  @override
  void processSignalFromPeer(String message) {}
}

extension RemoteScreenConnectorSorting on List<RemoteScreenConnector> {
  /// 依 senderName 英文字母升序（A→Z），不分大小寫。
  /// [nullsLast] 為 true 時，null 或空字串會排在最後。
  void sortBySenderNameAsc({bool nullsLast = true}) {
    sort((a, b) =>
        _compareSenderName(a, b, ascending: true, nullsLast: nullsLast));
  }

  /// 依 senderName 英文字母降序（Z→A），不分大小寫。
  /// [nullsLast] 為 true 時，null 或空字串會排在最後。
  void sortBySenderNameDesc({bool nullsLast = true}) {
    sort((a, b) =>
        _compareSenderName(a, b, ascending: false, nullsLast: nullsLast));
  }

  /// 依建立時間升序（舊→新）。時間相同時，以 senderName 升序作為次排序鍵。
  void sortByCreatedAtAsc({bool nullsLastForName = true}) {
    sort((a, b) => _compareCreatedAt(
          a,
          b,
          ascending: true,
          nullsLastForName: nullsLastForName,
        ));
  }

  /// 依建立時間降序（新→舊）。時間相同時，以 senderName 升序作為次排序鍵。
  void sortByCreatedAtDesc({bool nullsLastForName = true}) {
    sort((a, b) => _compareCreatedAt(
          a,
          b,
          ascending: false,
          nullsLastForName: nullsLastForName,
        ));
  }
}

int _compareSenderName(
  RemoteScreenConnector a,
  RemoteScreenConnector b, {
  required bool ascending,
  required bool nullsLast,
}) {
  final aName = a.senderName;
  final bName = b.senderName;

  final aEmpty = aName == null || aName.isEmpty;
  final bEmpty = bName == null || bName.isEmpty;
  if (aEmpty && bEmpty) return 0;
  if (aEmpty) return nullsLast ? 1 : -1;
  if (bEmpty) return nullsLast ? -1 : 1;

  // 英文字母不分大小寫比較；若僅大小寫不同，再用原字串比較確保穩定性
  final ci = aName.toLowerCase().compareTo(bName.toLowerCase());
  final primary = (ci != 0) ? ci : aName.compareTo(bName);

  return ascending ? primary : -primary;
}

int _compareCreatedAt(
  RemoteScreenConnector a,
  RemoteScreenConnector b, {
  required bool ascending,
  required bool nullsLastForName,
}) {
  final timeCmp = a.createdAt.compareTo(b.createdAt); // 舊 < 新
  if (timeCmp != 0) return ascending ? timeCmp : -timeCmp;

  // 若時間相同，以 senderName（升序、不分大小寫）作為 tie-breaker
  return _compareSenderName(a, b, ascending: true, nullsLast: nullsLastForName);
}
