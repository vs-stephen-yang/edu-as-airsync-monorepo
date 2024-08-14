import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_config.dart';

class Message {
  int seq; // the sequence number of the message

  Message(this.seq);

  Message.fromJson(
    Map<String, dynamic> json,
  ) : seq = json['seq'] as int;

  Map<String, dynamic> toJson() => {
        'seq': seq,
        'data': {
          'sdp': '',
        }
      };
}

class TunnelMessage {
  int seq; // the sequence number of the message
  String connectionId;

  TunnelMessage(this.connectionId, this.seq);

  TunnelMessage.fromJson(
    Map<String, dynamic> json,
  )   : seq = json['seq'] as int,
        connectionId = json['connectionId'] as String;

  Map<String, dynamic> toJson() => {
        'action': 'msg',
        'connectionId': connectionId,
        'data': {
          'seq': seq,
        }
      };
}

int countUniqueMessages(List<Message> messages) {
  final uniqueMessageSeqNumbers = <int>{};

  for (var message in messages) {
    uniqueMessageSeqNumbers.add(message.seq);
  }

  return uniqueMessageSeqNumbers.length;
}

class Runner {
  void Function()? onClientMessageReceived;
  void Function()? onServerMessageReceived;

  late WebSocket client;
  late WebSocket server;

  final clientReceived = <Message>[];
  final serverReceived = <Message>[];

  final int instanceIndex;
  final int groupId;
  final String instanceId;
  final String tunnelServiceUrl;

  String? _clientConnectionId;

  final _clientConnected = Completer();

  Runner({
    required this.instanceIndex,
    required this.groupId,
    required this.instanceId,
    required this.tunnelServiceUrl,
  });

  start() async {
    final clientId = const Uuid().v4();
    const token = '0000';
    const displayCode = 'ABCDEF';

    final clientUrl =
        '$tunnelServiceUrl?role=client&clientId=$clientId&instanceIndex=$instanceIndex&groupId=$groupId&token=$token&displayCode=$displayCode';

    final serverUrl =
        '$tunnelServiceUrl?role=server&instanceId=$instanceId&groupId=$groupId';

    // server
    server = await WebSocket.connect(serverUrl);

    server.listen(
      (dynamic data) {
        // receive data
        final tunnelMessage = jsonDecode(data);
        switch (tunnelMessage['action']) {
          case 'msg':
            final message = Message.fromJson(tunnelMessage['data']);
            serverReceived.add(message);

            onServerMessageReceived?.call();
            break;

          case 'connected':
            _clientConnectionId = tunnelMessage['connectionId'];
            _clientConnected.complete();
            break;
        }
      },
      cancelOnError: true,
    );

    await Future.delayed(const Duration(seconds: 1));

    // client
    client = await WebSocket.connect(clientUrl);

    client.listen(
      (dynamic data) {
        // receive data
        final message = Message.fromJson(jsonDecode(data));
        clientReceived.add(message);

        onClientMessageReceived?.call();
      },
      cancelOnError: true,
    );

    await _clientConnected.future;
  }

  // send messages to the server
  sendToServer(int count, int delayMs) async {
    for (var i = 0; i < count; i++) {
      client.add(
        jsonEncode(
          Message(i).toJson(),
        ),
      );

      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  // send messages to the client
  sendToClient(int count, int delayMs) async {
    for (var i = 0; i < count; i++) {
      final message = TunnelMessage(_clientConnectionId!, i);
      final data = jsonEncode(message.toJson());
      server.add(data);

      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }
}

class CounterCondition {
  final _completer = Completer();
  int _counter = 0;

  final int _expectedCount;

  CounterCondition(this._expectedCount);

  call() {
    _counter++;

    if (_counter >= _expectedCount) {
      _completer.complete();
    }
  }

  // wait until the counter reaches the expected value
  wait() async {
    await _completer.future;
  }
}

void main() {
  late Runner runner;

  setUp(() {
    return Future(() async {
      runner = Runner(
        groupId: groupId,
        instanceIndex: instanceIndex,
        instanceId: instanceId,
        tunnelServiceUrl: tunnelServiceUrl,
      );

      await runner.start();
    });
  });

  test('Ensure reliable message delivery from client to server', () async {
    // arrange
    final counter = CounterCondition(200);
    runner.onServerMessageReceived = () => counter();

    // action

    // send 200 messages to the server
    const delayMs = 100;
    await runner.sendToServer(200, delayMs);

    await counter.wait();

    // assert
    expect(runner.serverReceived.length, 200);
    expect(countUniqueMessages(runner.serverReceived), 200);
  });

  test('Ensure reliable message delivery from server to client.', () async {
    // arrange
    final counter = CounterCondition(200);
    runner.onClientMessageReceived = () => counter();

    // action

    // send 200 messages to the client
    const delayMs = 100;
    await runner.sendToClient(200, delayMs);

    await counter.wait();

    // assert
    expect(runner.clientReceived.length, 200);
    expect(countUniqueMessages(runner.clientReceived), 200);
  });

  test('Ensure reliable message delivery from server to client. consecutive',
      () async {
    // arrange
    final counter = CounterCondition(10);
    runner.onServerMessageReceived = () => counter();

    // action

    // send 10 consecutive messages to the server
    const delayMs = 0;
    await runner.sendToServer(10, delayMs);

    await counter.wait();

    // assert
    expect(runner.serverReceived.length, 10);
    expect(countUniqueMessages(runner.serverReceived), 10);
  });

  test('Ensure reliable message delivery from client to server. consecutive',
      () async {
    // arrange
    final counter = CounterCondition(10);
    runner.onClientMessageReceived = () => counter();

    // action

    // send 10 consecutive messages to the client
    const delayMs = 0; // consecutive
    await runner.sendToClient(10, delayMs);

    await counter.wait();

    // assert
    expect(runner.clientReceived.length, 10);
    expect(countUniqueMessages(runner.clientReceived), 10);
  });

  test('Ensure reliable message delivery from client to server. high-volume',
      () async {
    // arrange
    final counter = CounterCondition(100);
    runner.onServerMessageReceived = () => counter();

    // action

    // Send a large volume of messages in a short time to the server
    const delayMs = 1;
    await runner.sendToServer(100, delayMs);

    await counter.wait();

    // assert
    expect(runner.serverReceived.length, 100);
    expect(countUniqueMessages(runner.serverReceived), 100);
  });

  test('Ensure reliable message delivery from server to client. high-volume',
      () async {
    // arrange
    final counter = CounterCondition(100);
    runner.onClientMessageReceived = () => counter();

    // action

    // Send a large volume of messages in a short time to the client
    const delayMs = 1;
    await runner.sendToClient(100, delayMs);

    await counter.wait();

    // assert
    expect(runner.clientReceived.length, 100);
    expect(countUniqueMessages(runner.clientReceived), 100);
  });
}
