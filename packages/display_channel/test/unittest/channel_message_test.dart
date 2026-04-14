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
      final msg = ChannelConnectedMessage(1000, 1000, "token1", 17);

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as ChannelConnectedMessage;

      // assert
      expect(actual.heartbeatInterval, 1000);
      expect(actual.reconnectionToken, "token1");
      expect(actual.ack, 17);
    });

    test('client-connected', () {
      // arrange
      final msg = ClientConnectedMessage(27);

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as ClientConnectedMessage;

      // assert
      expect(actual.ack, 27);
    });

    test('display-status', () {
      // arrange
      final msg = DisplayStatusMessage();
      msg.seq = 0;
      msg.name = 'Room 1';
      msg.platform = 'Windows';
      msg.version = '2.5.2';
      msg.configuration = DisplayConfiguration();

      msg.status = DisplayStatus();
      msg.status!.moderator = true;

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as DisplayStatusMessage;

      // assert
      expect(actual.name, 'Room 1');
      expect(actual.platform, 'Windows');
      expect(actual.version, '2.5.2');

      expect(actual.status!.moderator, true);
    });

    test('join-display', () {
      // Arrange
      final msg = JoinDisplayMessage('12345');
      msg.name = 'Tom';
      msg.platform = 'Windows';
      msg.version = '1.5.1';
      msg.intent = JoinIntentType.present;

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as JoinDisplayMessage;

      // assert
      expect(actual.name, 'Tom');
      expect(actual.platform, 'Windows');
      expect(actual.clientId, '12345');
      expect(actual.version, '1.5.1');
      expect(actual.intent, JoinIntentType.present);
    });

    test('join-display intent remoteScreen', () {
      // Arrange
      final msg = JoinDisplayMessage('12345');
      msg.intent = JoinIntentType.remoteScreen;

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as JoinDisplayMessage;

      // assert
      expect(actual.intent, JoinIntentType.remoteScreen);
    });

    test('joint-display-rejected', () {
      // arrange
      final msg = JoinDisplayRejectedMessage();
      msg.reason = Reason(100, text: 'error1');

      //action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as JoinDisplayRejectedMessage;

      //assert
      expect(actual.reason!.code, 100);
      expect(actual.reason!.text, 'error1');
    });

    test('start-present', () {
      // Arrange
      final msg = StartPresentMessage('12345');
      msg.seq = 20;

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as StartPresentMessage;

      // assert
      expect(actual.seq, 20);
      expect(actual.sessionId, '12345');
    });

    test('present-accepted', () {
      // Arrange
      final msg = PresentAcceptedMessage('12345');

      final iceServer1 = RtcIceServer([
        'turn:ice.myviewboard.cloud:3478?transport=udp',
      ]);
      iceServer1.username = 'u1';
      iceServer1.credential = 's1';

      msg.iceServers.add(iceServer1);

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as PresentAcceptedMessage;

      // assert
      expect(actual.sessionId, '12345');

      expect(actual.iceServers[0].username, 'u1');
      expect(actual.iceServers[0].credential, 's1');
      expect(actual.iceServers[0].urls[0],
          'turn:ice.myviewboard.cloud:3478?transport=udp');
    });

    test('stop-present', () {
      // Arrange
      final msg = StopPresentMessage();
      msg.sessionId = '12345';
      msg.seq = 20;

      // action
      final json = msg.toJson();
      final actual = ChannelMessage.parse(json) as StopPresentMessage;

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
      final actual = ChannelMessage.parse(json) as PausePresentMessage;

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
      final actual = ChannelMessage.parse(json) as ResumePresentMessage;

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
      final actual = ChannelMessage.parse(json) as PresentSignalMessage;

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
      final actual = ChannelMessage.parse(json) as PresentSignalMessage;

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
    msg.reason = Reason(100, text: 'error');

    //action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as PresentRejectedMessage;

    //assert
    expect(actual.sessionId, '12345');
    expect(actual.reason!.code, 100);
    expect(actual.reason!.text, 'error');
  });

  test('change-present-quality', () {
    // Arrange
    final msg = ChangePresentQuality('12345');
    msg.seq = 20;
    msg.constraints = PresentQualityConstraints(frameRate: 30, height: 1080);

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as ChangePresentQuality;

    // assert
    expect(actual.seq, 20);
    expect(actual.sessionId, '12345');
    expect(actual.constraints!.frameRate, 30);
    expect(actual.constraints!.height, 1080);
  });

  test('channel-closed message', () {
    // Arrange
    final msg = ChannelClosedMessage(
      Reason(1, text: 'reason1'),
    );

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as ChannelClosedMessage;

    // assert
    expect(actual.reason!.code, 1);
    expect(actual.reason!.text, 'reason1');
  });

  test('start-remote-screen message', () {
    // Arrange
    final msg = StartRemoteScreenMessage('1000');

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as StartRemoteScreenMessage;

    // assert
    expect(actual.sessionId, '1000');
  });

  test('stop-remote-screen message', () {
    // Arrange
    final msg = StopRemoteScreenMessage('1000');

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as StopRemoteScreenMessage;

    // assert
    expect(actual.sessionId, '1000');
  });

  test('remote-screen-status message', () {
    // Arrange
    final msg = RemoteScreenStatusMessage('1000', RemoteScreenStatus.accepted);

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as RemoteScreenStatusMessage;

    // assert
    expect(actual.sessionId, '1000');
    expect(actual.status, RemoteScreenStatus.accepted);
  });

  test('remote-screen-info message', () {
    // Arrange
    final msg = RemoteScreenInfoMessage(
        '1000',
        IonSfuRoom(
          'ws://127.0.0.1:7999/dev',
          'room1',
        ));

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as RemoteScreenInfoMessage;

    // assert
    expect(actual.sessionId, '1000');
    expect(actual.ionSfuRoom!.url, 'ws://127.0.0.1:7999/dev');
    expect(actual.ionSfuRoom!.roomId, 'room1');
  });

  test('signalUrl should return url for old version', () {
    // Arrange
    final room = IonSfuRoom(
      'ws://127.0.0.1:7999/dev',
      'room1',
      signalOverChannel: null,
    );

    // action
    // assert
    expect(room.signalUrl, 'ws://127.0.0.1:7999/dev');
  });

  test('signalUrl should return null for new version', () {
    // Arrange
    final room = IonSfuRoom(
      'ws://127.0.0.1:7999/dev',
      'room1',
      signalOverChannel: true,
    );

    // action
    // assert
    expect(room.signalUrl, null);
  });

  test('remote-screen-info message with signalOverChannel', () {
    // Arrange
    final msg = RemoteScreenInfoMessage(
        '1000',
        IonSfuRoom(
          'ws://127.0.0.1:7999/dev',
          'room1',
          signalOverChannel: true,
        ));

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as RemoteScreenInfoMessage;

    // assert
    expect(actual.sessionId, '1000');
    expect(actual.ionSfuRoom!.url, 'ws://127.0.0.1:7999/dev');
    expect(actual.ionSfuRoom!.roomId, 'room1');
    expect(actual.ionSfuRoom!.signalOverChannel, true);
  });

  test('remote-screen-signal message', () {
    // Arrange
    final msg = RemoteScreenSignalMessage(
      '1000',
      '{"method":"offer"}',
    );

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as RemoteScreenSignalMessage;

    // assert
    expect(actual.sessionId, '1000');
    expect(actual.signal, '{"method":"offer"}');
  });

  test('invite-remote-screen message', () {
    // Arrange
    final msg = InviteRemoteScreenMessage(
      sessionId: '2000',
    );

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as InviteRemoteScreenMessage;

    // assert
    expect(actual.sessionId, '2000');
  });

  test('stop-display-group message', () {
    // Arrange
    final msg = StopDisplayGroupMessage(
      sessionId: '2000',
    );

    // action
    final json = msg.toJson();
    final actual = ChannelMessage.parse(json) as StopDisplayGroupMessage;

    // assert
    expect(actual.sessionId, '2000');
  });

  test('isControlMessage() should return false for non control messages', () {
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

  test('isControlMessage() should return true for control messages', () {
    // arrange
    final messages = [
      ChannelConnectedMessage(1000, 1000, 'token1', 5),
      ChannelClosedMessage(Reason(0)),
      ClientConnectedMessage(5),
      HeartbeatMessage(4),
    ];

    //action

    //assert
    expect(messages[0].isControlMessage, true);
    expect(messages[1].isControlMessage, true);
    expect(messages[2].isControlMessage, true);
    expect(messages[3].isControlMessage, true);
  });

  test('actionNameToChannelMessageType() should return correct enum type', () {
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
      actionNameToChannelMessageType('change-present-quality'),
      actionNameToChannelMessageType('allow-present'),
      actionNameToChannelMessageType('heartbeat'),
      actionNameToChannelMessageType('pause-present'),
      actionNameToChannelMessageType('resume-present'),
      actionNameToChannelMessageType('channel-closed'),
      actionNameToChannelMessageType('start-remote-screen'),
      actionNameToChannelMessageType('stop-remote-screen'),
      actionNameToChannelMessageType('remote-screen-status'),
      actionNameToChannelMessageType('remote-screen-info'),
      actionNameToChannelMessageType('remote-screen-signal'),
      actionNameToChannelMessageType('invite-display-group'),
      actionNameToChannelMessageType('invite-display-group-result'),
      actionNameToChannelMessageType('invite-remote-screen'),
      actionNameToChannelMessageType('stop-display-group'),
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
    expect(actual[9], ChannelMessageType.changePresentQuality);
    expect(actual[10], ChannelMessageType.allowPresent);
    expect(actual[11], ChannelMessageType.heartbeat);
    expect(actual[12], ChannelMessageType.pausePresent);
    expect(actual[13], ChannelMessageType.resumePresent);
    expect(actual[14], ChannelMessageType.channelClosed);
    expect(actual[15], ChannelMessageType.startRemoteScreen);
    expect(actual[16], ChannelMessageType.stopRemoteScreen);
    expect(actual[17], ChannelMessageType.remoteScreenStatus);
    expect(actual[18], ChannelMessageType.remoteScreenInfo);
    expect(actual[19], ChannelMessageType.remoteScreenSignal);
    expect(actual[20], ChannelMessageType.inviteDisplayGroup);
    expect(actual[21], ChannelMessageType.inviteDisplayGroupResult);
    expect(actual[22], ChannelMessageType.inviteRemoteScreen);
    expect(actual[23], ChannelMessageType.stopDisplayGroup);
  });

  test('actionNameToChannelMessageType() unknown', () {
    //arrange

    //action
    final actual = actionNameToChannelMessageType('xxxx-xxx');

    //assert
    expect(actual, ChannelMessageType.unknown);
  });
}
