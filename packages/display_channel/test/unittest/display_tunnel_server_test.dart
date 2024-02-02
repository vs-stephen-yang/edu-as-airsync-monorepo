import 'package:display_channel/display_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stop should work', () async {
    // arrange
    final server = DisplayTunnelServer(
      (String url) => WebSocketClientConnection(url),
      (Channel channel) {},
      (ConnectionRequest connectionRequest) => ConnectRequestStatus.success,
    );

    // action
    server.start('1000', 'wss://example.com/dev');
    server.stop();

    // assert
  });
}
