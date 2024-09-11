import 'dart:async';
import 'package:display_channel/display_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_config.dart';

int countByCloseCodes(
  List<DisplayChannelClient> clients,
  List<ChannelCloseCode> codes,
) {
  return clients
      .where(
        (e) => codes.contains(e.closeReason?.code),
      )
      .length;
}

void main() {
  late DisplayDirectServer directServer;
  late DisplayTunnelServer tunnelServer;

  late List<DisplayChannelClient> clients;

  Completer? tunnelServerConnectedCompleter;
  late List<Completer<void>> closedCompleters;

  Future startTunnelServer() async {
    // create a tunnel server
    tunnelServer = DisplayTunnelServer(
      (String url, bool isReconnect) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
            //logger: (url, message) => print('$url $message'),
            ),
      ),
      (Channel channel, queryParameters) => {},
      (ConnectionRequest connectRequest) {
        //print('Connect request ${connectRequest.clientId}');
        return ConnectRequestStatus.invalidOtp;
      },
    );

    tunnelServerConnectedCompleter = Completer();
    tunnelServer.onTunnelConnected = () {
      tunnelServerConnectedCompleter?.complete();
      tunnelServerConnectedCompleter = null;
    };

    // start the tunnel server
    tunnelServer.start(
      instanceId,
      groupId,
      Uri.parse(tunnelServiceUrl),
    );

    await tunnelServerConnectedCompleter?.future;
  }

  setUp(() {
    return Future(() async {
      clients = <DisplayChannelClient>[];

      closedCompleters = [];

      directServer = DisplayDirectServer(
        (Channel channel, queryParameters) {},
        (ConnectionRequest connectRequest) => ConnectRequestStatus.invalidOtp,
        maxBurstyRequests: 5,
        requestsPerSecond: 5,
      );

      // create a direct server
      await directServer.start(0);

      // start tunnel server
      await startTunnelServer();
    });
  });

  Future waitForClientsClosed() async {
    final futures = closedCompleters
        .map(
          (e) => e.future,
        )
        .toList();

    await Future.wait(futures);
  }

  void createClients(Uri uri, int count) {
    const clientIdPrefix = '04806e98';

    for (int i = 0; i < count; i++) {
      // create a client connection
      final client = DisplayChannelClient(
        '$clientIdPrefix-$i',
        uri,
        (url, bool reconnect) => WebSocketClientConnection(
          url,
          WebSocketClientConnectionConfig(
              retry: const RetryConfig(
                maxRetryAttempts: 1,
              ),
              logger: (String url, String message) {
                //print('$url $message');
              }),
        ),
      );

      final closedCompleter = Completer();
      closedCompleters.add(closedCompleter);

      client.onStateChange = (state) {
        //print('$clientIdPrefix-$i $state');
        if (state == ChannelState.closed) {
          closedCompleter.complete();
        }
      };
      clients.add(client);
    }
  }

  // submit connection requests
  Future submitRequests(
    Function(DisplayChannelClient client, int index) open,
    int count,
    Duration duration,
  ) async {
    final startTime = DateTime.now();

    for (int i = 0; i < count; i++) {
      // open the connection
      open(clients[i], i);

      // delay between consecutive connection requests
      final elapse = DateTime.now().difference(startTime);
      final nextSubmitTimeMs = ((i + 1) * duration.inMilliseconds) ~/ count;

      final delayMs = nextSubmitTimeMs - elapse.inMilliseconds;
      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  test(
    'The direct server should correctly enforce rate limiting',
    skip: true,
    timeout: const Timeout(Duration(seconds: 10)),
    () async {
      // Arrange
      final uri = Uri(
        scheme: 'ws',
        host: "127.0.0.1",
        port: directServer.port!,
      );
      createClients(uri, 50);

      // Action
      await submitRequests(
        (client, index) => client.openDirectChannel(
          token: '0000',
          displayCode: 'AVA',
        ),
        clients.length, // 50 connection requests in 5 seconds
        const Duration(seconds: 5),
      );

      // Wait until all clients are closed.
      await waitForClientsClosed();

      // Assert
      final count = countByCloseCodes(
        clients,
        [ChannelCloseCode.authenticationError],
      );

      // Ensure about 25 requests are allowed
      expect(count, lessThan(30));
      expect(count, greaterThan(20));
    },
  );

  test(
    'The tunnel service should correctly enforce rate limiting: 40 requests per minutes',
    skip: true,
    timeout: const Timeout(Duration(seconds: 130)),
    () async {
      // Arrange
      final uri = Uri.parse(tunnelServiceUrl);
      createClients(uri, 100);

      // Action
      await submitRequests(
        (client, index) => client.openTunnelChannel(
          instanceIndex,
          groupId,
          '0000',
          displayCode: 'AVA',
        ),
        clients.length, // 100 connection requests in 2 minutes
        const Duration(minutes: 2),
      );

      // Wait until all clients are closed.
      await waitForClientsClosed();

      // Assert
      final count = countByCloseCodes(
        clients,
        [ChannelCloseCode.authenticationError],
      );

      // Ensure about 80 requests are allowed
      expect(count, lessThan(85));
      expect(count, greaterThan(75));
    },
  );
}
