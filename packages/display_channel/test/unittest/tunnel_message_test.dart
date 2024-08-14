import 'package:flutter_test/flutter_test.dart';

import 'package:display_channel/src/server/tunnel/tunnel_message.dart';

void main() {
  group('message serialization', () {
    test('client connected', () {
      // arrange
      final msg = TunnelClientConnected(
        "connection1",
        "client1",
        "token1",
        'ABA',
      );

      // action
      final json = msg.toJson();
      final actual = TunnelClientConnected.fromJson(json);

      // assert
      expect(actual.clientId, "client1");
      expect(actual.connectionId, "connection1");
      expect(actual.token, "token1");
    });

    test('client disconnected', () {
      // arrange
      final msg = TunnelClientDisconnected(
        "connection1",
      );

      // action
      final json = msg.toJson();
      final actual = TunnelClientDisconnected.fromJson(json);

      // assert
      expect(actual.connectionId, "connection1");
    });

    test('client disconnected', () {
      const data = {
        "color": "red",
        "body": {
          "hand": "large",
        }
      };

      // arrange
      final msg = TunnelClientMsg(
        "connection1",
        data,
      );

      // action
      final json = msg.toJson();
      final actual = TunnelClientMsg.fromJson(json);

      // assert
      expect(actual.connectionId, "connection1");
      expect(actual.data, {
        "color": "red",
        "body": {
          "hand": "large",
        }
      });
    });
  });
}
