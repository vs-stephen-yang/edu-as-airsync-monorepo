import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:display_channel/display_channel.dart';

import 'test_util.dart';

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

// Create a WebSocket for the tunnel server
Future<WebSocket> createWebSocketAsServer(
  String origin,
  String instanceId,
) {
  final request = buildApiRequest(
    origin,
    '',
    queryParameters: {
      'role': 'server',
      'instanceId': instanceId,
    },
    time: DateTime.now(),
    signatureLocation: SignatureLocation.queryString,
  );

  return WebSocket.connect(request.url.toString());
}

// Create a WebSocket for the tunnel client
Future<WebSocket> createWebSocketAsClient(
  String origin,
  int instanceIndex,
  int groupId,
  String clientId,
) {
  final request = buildApiRequest(
    origin,
    '',
    queryParameters: {
      'role': 'client',
      'instanceIndex': '$instanceIndex',
      'groupId': '$groupId',
      'clientId': clientId,
      'token': '0000',
      'displayCode': '11111111',
    },
    time: DateTime.now(),
    signatureLocation: SignatureLocation.queryString,
  );

  return WebSocket.connect(request.url.toString());
}

class Client {
  final WebSocket _ws;

  final messages = <Message>[];

  CounterCondition? receivedCounter;

  Client(this._ws) {
    _ws.listen(
      (dynamic data) {
        // A message is received from the server
        final message = Message.fromJson(jsonDecode(data));
        messages.add(message);

        receivedCounter?.call();
      },
      cancelOnError: true,
    );
  }

  Future<void> sendMessages({
    required int count,
    required int delayMs,
  }) async {
    for (var i = 0; i < count; i++) {
      _ws.add(
        jsonEncode(
          Message(i).toJson(),
        ),
      );

      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }
}

class TunnelConnection {
  String connectionId;
  final messages = <Message>[];

  CounterCondition? receivedCounter;

  final Function(TunnelMessage) _send;

  TunnelConnection(
    this.connectionId,
    this._send,
  );

  // A message is received from the client
  void onMessage(Message message) {
    messages.add(message);
    receivedCounter?.call();
  }

  // Send messages to the client
  Future<void> sendMessages({
    required int count,
    required int delayMs,
  }) async {
    for (var i = 0; i < count; i++) {
      _send(
        TunnelMessage(connectionId, i),
      );

      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }
}

class TunnelServer {
  final WebSocket _ws;

  final connections = <String, TunnelConnection>{};
  CounterCondition? connectionCounter;

  final void Function(TunnelConnection connection) _onClientConnected;

  TunnelServer(
    this._ws,
    this._onClientConnected,
  ) {
    _ws.listen(
      (dynamic data) {
        // receive data
        final tunnelMessage = jsonDecode(data);
        switch (tunnelMessage['action']) {
          case 'msg':
            final connectionId = tunnelMessage['connectionId'];
            final message = Message.fromJson(tunnelMessage['data']);

            connections[connectionId]?.onMessage(message);
            break;

          case 'connected':
            final connectionId = tunnelMessage['connectionId'];

            final connection = TunnelConnection(
              connectionId,
              (TunnelMessage message) {
                _ws.add(jsonEncode(message.toJson()));
              },
            );
            connections[connectionId] = connection;

            _onClientConnected(connection);
            break;
        }
      },
      cancelOnError: true,
    );
  }
}
