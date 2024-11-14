import 'dart:async';

import 'package:display_channel/src/messages/channel_message.dart';

enum ChannelState {
  initialized,
  connecting,
  connected,
  closed,
}

enum ChannelCloseCode {
  close,
  remoteClose,
  instanceNotFound,
  authenticationError,
  networkError,
  heartbeatTimeout,
  remoteUnknown,
  invalidDisplayCode,
  rateLimitExceeded,
  authenticationRequired,
}

class ChannelCloseReason {
  ChannelCloseCode code;
  String? text;

  ChannelCloseReason(
    this.code, {
    this.text,
  });
}

abstract class Channel {
  Stream<ChannelState> get stateStream;
  Stream<ChannelMessage> get messageStream;

  ChannelState get state;

  ChannelCloseReason? get closeReason;

  Future<void> close(ChannelCloseReason? reason);

  void send(ChannelMessage message);
}
