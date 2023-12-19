import 'package:display_channel/src/messages/channel_message.dart';

enum ChannelState {
  initialized,
  connecting,
  connected,
  disconnected,
  closed,
}

enum ChannelCloseCode {
  close,
  remoteClose,
  channelNotFound,
  authenticationError,
  transportClose,
  heartbeatTimeout,
  remoteUnknown,
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
  void Function(ChannelState state)? onStateChange;

  void Function(ChannelMessage message)? onChannelMessage;

  ChannelState get state;
  ChannelCloseReason? get closeReason;

  Future<void> close(ChannelCloseReason? reason);

  void send(ChannelMessage message);
}
