import 'package:display_channel/src/messages/incoming_message_queue.dart';
import 'package:display_channel/src/messages/outgoing_message_queue.dart';
import 'package:display_channel/src/messages/channel_message.dart';

enum MessageContinuityRole {
  client,
  server,
}

class MessageContinuity {
  final _incomingMessageQueue = IncomingMessageQueue<ChannelMessage>();
  final _outgoingMessageQueue = OutgoingMessageQueue<ChannelMessage>();

  final MessageContinuityRole _role;

  final void Function(ChannelMessage message) _onMessageReceived;
  final void Function(ChannelMessage message) _onMessageSend;

  int get nextIncomingSequenceNumber =>
      _incomingMessageQueue.nextSequenceNumber;

  int get earliestOutgoingSequenceNumber =>
      _outgoingMessageQueue.earliestMessageSequenceNumber;

  MessageContinuity(
    this._role,
    this._onMessageReceived,
    this._onMessageSend,
  );

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
        _onChannelConnectedReceived(message as ChannelConnectedMessage);
        break;
      case ChannelMessageType.clientConnected:
        _onClientConnectedReceived(message as ClientConnectedMessage);
        break;
      case ChannelMessageType.heartbeat:
        _onHeartbeatReceived(message as HeartbeatMessage);
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
      _onMessageReceived(m);
    } while (true);
  }

  ChannelMessage prepareOutgoingMessage(ChannelMessage message) {
    assert(message.seq == null);

    if (message.isControlMessage) {
      // do not assign sequence number for control messages
      return message;
    }

    // assign the sequence number and save to the queue
    message.seq = _outgoingMessageQueue.pushMessage(message);
    return message;
  }

  // receive the hearbeat from the peer
  void _onHeartbeatReceived(HeartbeatMessage message) {
    if (message.ack != null) {
      _onHeartbeatAck(message.ack!);
    }
  }

  void _onClientConnectedReceived(ClientConnectedMessage message) {
    // This message is only received by the server
    assert(_role == MessageContinuityRole.server);

    if (message.ack != null) {
      _onConnectedAck(message.ack!);
    }
  }

  void _onChannelConnectedReceived(ChannelConnectedMessage message) {
    // This message is only received by the client
    assert(_role == MessageContinuityRole.client);

    if (message.ack != null) {
      _onConnectedAck(message.ack!);
    }
  }

  // All messages before the ack, excluding the ack itself, have already been received.
  void _onHeartbeatAck(int ack) {
    // Remove messages that have already been received by the peer.
    _outgoingMessageQueue.removeMessagesBefore(ack);
  }

  void _onConnectedAck(int ack) {
    if (!_isValidAck(ack)) {
      return;
    }

    _retransmitMessages(ack);
  }

  bool _isValidAck(int ack) {
    return ack >= _outgoingMessageQueue.earliestMessageSequenceNumber;
  }

  void _retransmitMessages(int ack) {
    for (int seq = ack; seq < _outgoingMessageQueue.nextSequenceNumber; seq++) {
      final message = _outgoingMessageQueue.getMessage(seq);

      if (message != null) {
        assert(message.seq != null);

        _onMessageSend(message);
      }
    }
  }
}
