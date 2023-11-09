import 'package:display_channel/src/messages/channel_message.dart';

enum ChannelState {
  initialized,
  connecting,
  connected,
  disconnected,
  failed,
}

abstract class Channel {
  void Function(ChannelState state)? onStateChange;

  void Function(ChannelMessage message)? onChannelMessage;

  ChannelState get state;

  void close();

  void send(ChannelMessage message);
}
