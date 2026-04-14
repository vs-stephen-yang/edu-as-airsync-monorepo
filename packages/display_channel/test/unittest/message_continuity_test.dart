import 'package:display_channel/src/messages/channel_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/src/messages/message_continuity.dart';

import 'utils.dart';

// Checks if messages are in sequential order based on their sequence numbers.
bool isMessageInOrder(List<ChannelMessage> messages) {
  for (int i = 1; i < messages.length; i++) {
    if (messages[i - 1].seq! >= messages[i].seq!) {
      return false;
    }
  }
  return true;
}

processIncomingMessages(MessageContinuity mc, List<ChannelMessage> messages) {
  for (var message in messages) {
    mc.processIncomingMessage(message);
  }
}

prepareOutgoingMessages(MessageContinuity mc, List<ChannelMessage> messages) {
  for (var message in messages) {
    mc.prepareOutgoingMessage(message);
  }
}

// create a MessageContinuity with client role
MessageContinuity createClient(
  List<ChannelMessage>? incomingMessages,
  List<ChannelMessage>? outgoingMessages,
) {
  return MessageContinuity(
    MessageContinuityRole.client,
    (message) => incomingMessages?.add(message),
    (message) => outgoingMessages?.add(message),
  );
}

// create a MessageContinuity with server role
MessageContinuity createServer(
  List<ChannelMessage>? incomingMessages,
  List<ChannelMessage>? outgoingMessages,
) {
  return MessageContinuity(
    MessageContinuityRole.server,
    (message) => incomingMessages?.add(message),
    (message) => outgoingMessages?.add(message),
  );
}

void main() {
  late List<ChannelMessage> outgoingMessages1;
  late List<ChannelMessage> incomingMessages1;

  setUp(() {
    outgoingMessages1 = buildMessages([0, 1, 2, 3, 4], false);

    incomingMessages1 = buildMessages([0, 3, 2, 1], true);
  });

  test('nextIncomingSequenceNumber should start with 0', () {
    // arrange
    final mc = createClient(null, null);

    // assert
    expect(mc.nextIncomingSequenceNumber, 0);
  });

  test('the incoming messages should be reordered correctly', () {
    // arrange
    final actualMessages = <ChannelMessage>[];

    final mc = createClient(actualMessages, null);

    // action
    processIncomingMessages(mc, incomingMessages1);

    // assert
    expect(actualMessages.length, 4);
    expect(isMessageInOrder(actualMessages), true);
  });

  test('nextIncomingSequenceNumber should update correctly', () {
    // arrange
    final actualMessages = <ChannelMessage>[];

    final mc = createClient(actualMessages, null);

    // action
    processIncomingMessages(mc, incomingMessages1);

    // assert
    expect(mc.nextIncomingSequenceNumber, 4);
  });

  test(
      'The client should retransmit messages based on the ack in channel-connected',
      () {
    // arrange
    final actualMessages = <ChannelMessage>[];

    final mc = createClient(null, actualMessages);

    prepareOutgoingMessages(mc, outgoingMessages1);

    // action
    mc.processIncomingMessage(
      ChannelConnectedMessage(1000, 1000, '', 3),
    );

    // assert
    expect(actualMessages.length, 2);

    expect((actualMessages[0] as StartPresentMessage).sessionId, "3");
    expect((actualMessages[1] as StartPresentMessage).sessionId, "4");
  });

  test(
      'The server should retransmit messages based on the ack in client-connected',
      () {
    // arrange
    final actualMessages = <ChannelMessage>[];

    final mc = createServer(null, actualMessages);

    prepareOutgoingMessages(mc, outgoingMessages1);

    // action
    mc.processIncomingMessage(
      ClientConnectedMessage(3),
    );

    // assert
    expect(actualMessages.length, 2);

    expect((actualMessages[0] as StartPresentMessage).sessionId, "3");
    expect((actualMessages[1] as StartPresentMessage).sessionId, "4");
  });

  test('Acknowledged messages should be removed based on the ack in heartbeat',
      () {
    // arrange
    final mc = createClient(null, null);

    prepareOutgoingMessages(mc, outgoingMessages1);

    // action
    mc.processIncomingMessage(
      HeartbeatMessage(3),
    );

    // assert
    expect(mc.earliestOutgoingSequenceNumber, 3);
  });
}
