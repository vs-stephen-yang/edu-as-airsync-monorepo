import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:display_channel/src/messages/channel_message.dart';

void main() {
  group('message serialization', () {
    test('ChannelMessage.parse', () {
      // arrange
      const data = """
          {
            "action":"display-status",
            "seq": 5,
            "data":{
              "name": "Room 1"
            }
          }
          """;

      //action
      final json = jsonDecode(data);

      DisplayStatusMessage? message =
          ChannelMessage.parse(json) as DisplayStatusMessage;

      //assert
      expect(message.messageType, ChannelMessageType.displayStatus);
      expect(message.name, "Room 1");
      expect(message.seq, 5);
    });

    test('ChannelMessage.parse unknown', () {
      // arrange
      const data = """
          {
            "action":"unknown-unknown",
            "seq": 5
          }
          """;

      //action
      final json = jsonDecode(data);

      ChannelMessage? message = ChannelMessage.parse(json);

      //assert
      expect(message, null);
    });

    test('channel-connected', () {
      // arrange
      final msg = ChannelConnectedMessage(1000, "token1");

      // action
      final json = msg.toJson();
      final actual = ChannelConnectedMessage.fromJson(json);

      // assert
      expect(actual.heartbeatInterval, 1000);
      expect(actual.reconnectionToken, "token1");
    });

    test('display-status', () {
      // arrange
      final msg = DisplayStatusMessage();
      msg.seq = 0;
      msg.name = 'Room 1';
      msg.platform = 'Windows';
      msg.version = '2.5.2';
      msg.configuration = DisplayConfiguration();

      final iceServer1 = RtcIceServer([
        'turn:ice.myviewboard.cloud:3478?transport=udp',
      ]);
      iceServer1.username = 'u1';
      iceServer1.credential = 's1';

      msg.configuration!.iceServers.add(iceServer1);

      msg.status = DisplayStatus();
      msg.status!.moderator = true;

      // action
      final json = msg.toJson();
      final actual = DisplayStatusMessage.fromJson(json);

      // assert
      expect(actual.name, 'Room 1');
      expect(actual.platform, 'Windows');
      expect(actual.version, '2.5.2');

      expect(actual.configuration!.iceServers[0].username, 'u1');
      expect(actual.configuration!.iceServers[0].credential, 's1');
      expect(actual.configuration!.iceServers[0].urls[0],
          'turn:ice.myviewboard.cloud:3478?transport=udp');

      expect(actual.status!.moderator, true);
    });

    test('join-display', () {
      // Arrange
      final msg = JoinDisplayMessage('12345');
      msg.name = 'Tom';
      msg.platform = 'Windows';
      msg.version = '1.5.1';

      // action
      final json = msg.toJson();
      final actual = JoinDisplayMessage.fromJson(json);

      // assert
      expect(actual.name, 'Tom');
      expect(actual.platform, 'Windows');
      expect(actual.clientId, '12345');
      expect(actual.version, '1.5.1');
    });

    test('start-present', () {
      // Arrange
      final msg = StartPresentMessage('12345');
      msg.seq = 20;

      // action
      final json = msg.toJson();
      final actual = StartPresentMessage.fromJson(json);

      // assert
      expect(actual.seq, 20);
      expect(actual.sessionId, '12345');
    });

    test('pause-present', () {
      // Arrange
      final msg = PausePresentMessage('12345');
      msg.seq = 20;

      // action
      final json = msg.toJson();
      final actual = PausePresentMessage.fromJson(json);

      // assert
      expect(actual.seq, 20);
      expect(actual.sessionId, '12345');
    });

    test('resume-present', () {
      // Arrange
      final msg = ResumePresentMessage('12345');
      msg.seq = 20;

      // action
      final json = msg.toJson();
      final actual = ResumePresentMessage.fromJson(json);

      // assert
      expect(actual.seq, 20);
      expect(actual.sessionId, '12345');
    });

    test('present-signal sdp', () {
      // Arrange
      final msg = PresentSignalMessage(
        '12345',
        SignalMessageType.answer,
      );

      msg.seq = 24;
      msg.sdp = 'abcdef';

      // action
      final json = msg.toJson();
      final actual = PresentSignalMessage.fromJson(json);

      // assert
      expect(actual.seq, 24);
      expect(actual.sessionId, '12345');
      expect(actual.signalType, SignalMessageType.answer);
      expect(actual.sdp, 'abcdef');
    });

    test('present-signal candidate', () {
      // Arrange
      final msg = PresentSignalMessage(
        '12345',
        SignalMessageType.candidate,
      );

      msg.candidate =
          'candidate:4159140876 1 udp 2113937151 707cf326-155c.local 51660 typ host generation 0 ufrag imVi network-cost 999';
      msg.sdpMLineIndex = 0;
      msg.sdpMid = "0";

      // action
      final json = msg.toJson();
      final actual = PresentSignalMessage.fromJson(json);

      // assert
      expect(actual.sessionId, '12345');
      expect(actual.signalType, SignalMessageType.candidate);
      expect(actual.candidate,
          'candidate:4159140876 1 udp 2113937151 707cf326-155c.local 51660 typ host generation 0 ufrag imVi network-cost 999');
      expect(actual.sdpMLineIndex, 0);
      expect(actual.sdpMid, '0');
    });
  });

  test('present-rejected', () {
    // arrange
    final msg = PresentRejectedMessage();
    msg.sessionId = '12345';
    msg.reason = PresentRejectReason(100, 'error');

    //action
    final json = msg.toJson();
    final actual = PresentRejectedMessage.fromJson(json);

    //assert
    expect(actual.sessionId, '12345');
    expect(actual.reason!.code, 100);
    expect(actual.reason!.text, 'error');
  });

  test('isControlMessage should return false for non control messages', () {
    // arrange
    final messages = [
      DisplayStatusMessage(),
      StartPresentMessage("1234"),
    ];

    //action

    //assert
    expect(messages[0].isControlMessage, false);
    expect(messages[1].isControlMessage, false);
  });

  test('isControlMessage should return true for control messages', () {
    // arrange
    final messages = [
      ChannelConnectedMessage(1000, 'token1'),
      ClientConnectedMessage(5),
      HeartbeatMessage(4),
    ];

    //action

    //assert
    expect(messages[0].isControlMessage, true);
    expect(messages[1].isControlMessage, true);
    expect(messages[2].isControlMessage, true);
  });

  test('actionNameToChannelMessageType()', () {
    // arrange

    //action
    final actual = [
      actionNameToChannelMessageType('channel-connected'),
      actionNameToChannelMessageType('client-connected'),
      actionNameToChannelMessageType('display-status'),
      actionNameToChannelMessageType('join-display'),
      actionNameToChannelMessageType('start-present'),
      actionNameToChannelMessageType('present-accepted'),
      actionNameToChannelMessageType('present-rejected'),
      actionNameToChannelMessageType('stop-present'),
      actionNameToChannelMessageType('present-signal'),
      actionNameToChannelMessageType('present-change-quality'),
      actionNameToChannelMessageType('allow-present'),
      actionNameToChannelMessageType('heartbeat'),
    ];

    //assert
    expect(actual[0], ChannelMessageType.channelConnected);
    expect(actual[1], ChannelMessageType.clientConnected);
    expect(actual[2], ChannelMessageType.displayStatus);
    expect(actual[3], ChannelMessageType.joinDisplay);
    expect(actual[4], ChannelMessageType.startPresent);
    expect(actual[5], ChannelMessageType.presentAccepted);
    expect(actual[6], ChannelMessageType.presentRejected);
    expect(actual[7], ChannelMessageType.stopPresent);
    expect(actual[8], ChannelMessageType.presentSignal);
    expect(actual[9], ChannelMessageType.presentChangeQuality);
    expect(actual[10], ChannelMessageType.allowPresent);
    expect(actual[11], ChannelMessageType.heartbeat);
  });

  test('actionNameToChannelMessageType() unknown', () {
    //arrange

    //action
    final actual = actionNameToChannelMessageType('xxxx-xxx');

    //assert
    expect(actual, ChannelMessageType.unknown);
  });
}
