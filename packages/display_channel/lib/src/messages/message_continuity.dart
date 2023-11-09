import 'package:display_channel/src/messages/incoming_message_queue.dart';
import 'package:display_channel/src/messages/outgoing_message_queue.dart';
import 'package:display_channel/src/messages/channel_message.dart';

class MessageContinuity {
  final _incomingMessageQueue = IncomingMessageQueue<ChannelMessage>();
  final _outgoingMessageQueue = OutgoingMessageQueue<ChannelMessage>();

  final void Function(ChannelMessage message) _onChannelMessage;

  MessageContinuity(this._onChannelMessage);

  void processIncomingMessage(ChannelMessage message) {
    if (message.isControlMessage) {
      _handleControlMessage(message);
    } else {
      _handleMessage(message);
    }
  }

  void _handleControlMessage(ChannelMessage message) {
    switch (message.messageType) {
      case ChannelMessageType.channelConnected:
        _onChannelConnected(message as ChannelConnectedMessage);
        break;
      case ChannelMessageType.heartbeat:
        _onHeartbeat(message as HeartbeatMessage);
        break;
      default:
        return;
    }
  }

  void _handleMessage(ChannelMessage message) {
    if (message.seq == null) {
      return;
    }

    _incomingMessageQueue.addMessage(message.seq!, message);

    do {
      final m = _incomingMessageQueue.popNextMessage();
      if (m == null) {
        break;
      }
      _onChannelMessage(m);
    } while (true);
  }

  ChannelMessage prepareOutgoingMessage(ChannelMessage message) {
    if (message.isControlMessage) {
      // do not assign sequence number for control messages
      return message;
    }

    // assign the sequence number and save to the queue
    message.seq = _outgoingMessageQueue.pushMessage(message);
    return message;
  }

  ChannelMessage buildHeartbeatMessage() {
    final ack = _incomingMessageQueue.nextSequenceNumber;

    return HeartbeatMessage(ack);
  }

  void _onHeartbeat(HeartbeatMessage message) {
    if (message.ack == null) {
      return;
    }

    _onAck(message.ack!);
  }

  void _onChannelConnected(ChannelConnectedMessage message) {
    if (message.ack == null) {
      return;
    }

    _onAck(message.ack!);
  }

  // All messages before the ack, excluding the ack itself, have already been received.
  void _onAck(int ack) {
    _outgoingMessageQueue.removeMessagesBefore(ack);
  }
}
