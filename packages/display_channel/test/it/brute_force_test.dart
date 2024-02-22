import 'dart:async';
import 'package:display_channel/display_channel.dart';
import 'package:flutter_test/flutter_test.dart';

const tunnelServiceUrl = 'wss://ap-northeast-1.gateway.dev.airsync.net';

const defaultInstanceIndex = '100043';
const defaultInstanceId = '0001';

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
      (String url) => WebSocketClientConnection(url),
      (Channel channel) => {},
      (ConnectionRequest connectRequest) {
        return ConnectRequestStatus.invalidOtp;
      },
    );

    tunnelServerConnectedCompleter = Completer();
    tunnelServer.onTunnelConnected = () {
      tunnelServerConnectedCompleter?.complete();
      tunnelServerConnectedCompleter = null;
    };

    // start the tunnel server
    tunnelServer.start(defaultInstanceId, tunnelServiceUrl);

    await tunnelServerConnectedCompleter?.future;
  }

  setUp(() {
    return Future(() async {
      clients = <DisplayChannelClient>[];

      closedCompleters = [];

      directServer = DisplayDirectServer(
        (Channel channel) {},
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
        (url) => WebSocketClientConnection(url, maxRetryAttempts: 1),
      );

      final closedCompleter = Completer();
      closedCompleters.add(closedCompleter);

      client.onStateChange = (state) {
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
    timeout: const Timeout(Duration(seconds: 10)),
    () async {
      // arrange
      final uri = Uri(
        scheme: 'ws',
        host: "127.0.0.1",
        port: directServer.port!,
      );
      createClients(uri, 50);

      // action
      await submitRequests(
        (client, index) => client.openDirectChannel('0000', displayCode: 'AVA'),
        50, // 50 connection requests in 5 seconds
        const Duration(seconds: 5),
      );

      // Wait until all clients are closed.
      await waitForClientsClosed();

      // assert
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
    'The tunnel service should correctly enforce rate limiting',
    timeout: const Timeout(Duration(seconds: 10)),
    () async {
      // arrange
      final uri = Uri.parse(tunnelServiceUrl);
      createClients(uri, 50);

      // action
      await submitRequests(
        (client, index) => client.openTunnelChannel(
          defaultInstanceIndex,
          '0000',
          displayCode: 'AVA',
        ),
        50, // 50 connection requests in 5 seconds
        const Duration(seconds: 5),
      );

      // Wait until all clients are closed.
      await waitForClientsClosed();

      // assert
      final count = countByCloseCodes(
        clients,
        [ChannelCloseCode.authenticationError],
      );

      // Ensure about 25 requests are allowed
      expect(count, lessThan(30));
      expect(count, greaterThan(20));
    },
  );
}
