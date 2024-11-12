import 'dart:async';

import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'test_util.dart';

int countClientsByCloseCodes(
  List<DisplayChannelClient> clients,
  List<ChannelCloseCode> codes,
) {
  return clients
      .where(
        (e) => codes.contains(e.closeReason?.code),
      )
      .length;
}

List<DisplayChannelClient> createClients(
  Uri uri,
  List<Completer<void>> closedCompleters,
  int count,
) {
  final clients = <DisplayChannelClient>[];

  for (int i = 0; i < count; i++) {
    final client = DisplayChannelClient(
      '$i',
      uri,
      (url, bool reconnect) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
            retry: const RetryConfig(
              maxRetryAttempts: 1,
            ),
            logger: (String url, String message) {}),
      ),
    );

    final closedCompleter = Completer();
    closedCompleters.add(closedCompleter);

    client.stateController.stream.listen((ChannelState state) {
      if (state == ChannelState.closed) {
        closedCompleter.complete();
      }
    });
    clients.add(client);
  }
  return clients;
}

Future<DisplayTunnelServer> startTunnelServer(
  String instanceId,
  int groupId,
  String tunnelApiUrl,
) async {
  final server = DisplayTunnelServer(
    (String url, bool isReconnect) => WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(),
    ),
    (Channel channel, queryParameters) => {},
    (ConnectionRequest connectRequest) => ConnectRequestStatus.invalidOtp,
  );

  final connectedCompleter = Completer();

  server.onTunnelConnected = () {
    connectedCompleter.complete();
  };

  // Start the tunnel server
  server.start(
    instanceId,
    groupId,
    Uri.parse(tunnelApiUrl),
  );

  await connectedCompleter.future;

  return server;
}

// Submit connection requests
Future submitRequests(
  List<DisplayChannelClient> clients,
  Function(DisplayChannelClient client, int index) open,
  Duration duration,
) async {
  final startTime = DateTime.now();

  for (int i = 0; i < clients.length; i++) {
    open(clients[i], i);

    // delay between consecutive connection requests
    final elapse = DateTime.now().difference(startTime);
    final nextSubmitTimeMs =
        ((i + 1) * duration.inMilliseconds) ~/ clients.length;

    final delayMs = nextSubmitTimeMs - elapse.inMilliseconds;
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }
}

void main() {
  const instanceGroupId = 1;
  final apiOrigin = getApiOriginFromEnv();

  const instanceIds = [
    'test-53b8deaf-6bd2-4e36-8c45-a4a80107d0b2-1',
    'test-53b8deaf-6bd2-4e36-8c45-a4a80107d0b2-2'
  ];

  late List<RegisterInstanceResult> instanceInfos = <RegisterInstanceResult>[];

  late DisplayDirectServer directServer;

  late List<DisplayTunnelServer> tunnelServers = <DisplayTunnelServer>[];

  Future<void> submitDirectRequests(
    List<DisplayChannelClient> clients,
    Duration duration,
  ) async {
    await scheduleTasks(
      clients,
      (client, index) async {
        client.openDirectChannel();
      },
      duration,
    );
  }

  Future<void> submitTunnelRequests(
    List<DisplayChannelClient> clients,
    int instanceIndex,
    Duration duration,
  ) async {
    await scheduleTasks(
      clients,
      (client, index) async {
        client.openTunnelChannel(
          instanceIndex,
          instanceGroupId,
          '0000',
          displayCode: '1234',
        );
      },
      duration,
    );
  }

  setUp(() {
    return Future(() async {
      directServer = DisplayDirectServer(
        (Channel channel, queryParameters) {},
        (ConnectionRequest connectRequest) => ConnectRequestStatus.invalidOtp,
        maxBurstyRequests: 5,
        requestsPerSecond: 5,
      );

      // start the direct server
      await directServer.start(0);

      // start two tunnel servers
      for (var i = 0; i < 2; i++) {
        instanceInfos.add(await registerInstance(
          apiOrigin,
          instanceIds[i],
          instanceGroupId,
        ));

        tunnelServers.add(await startTunnelServer(
          instanceIds[i],
          instanceGroupId,
          instanceInfos[i].tunnelApiUrl,
        ));
      }
    });
  });

  test(
    'The direct server should correctly enforce rate limiting',
    tags: ['slow'],
    timeout: const Timeout(Duration(seconds: 10)),
    () async {
      // Arrange
      final uri = Uri(
        scheme: 'ws',
        host: "127.0.0.1",
        port: directServer.port!,
      );
      final closedCompleters = <Completer<void>>[];

      final clients = createClients(uri, closedCompleters, 50);

      // Action
      await submitDirectRequests(
        clients,
        const Duration(seconds: 5),
      );

      // Wait until all clients are closed.
      await waitForAllCompleted(closedCompleters);

      // Assert
      final count = countClientsByCloseCodes(
        clients,
        [ChannelCloseCode.authenticationError],
      );

      // Ensure about 25 requests are allowed
      expect(count, lessThan(30));
      expect(count, greaterThan(20));
    },
  );

  test(
    'API should allow at least 40 successful instance info requests per minute',
    tags: ['slow'],
    timeout: const Timeout(Duration(seconds: 130)),
    () async {
      final instanceId = const Uuid().v4();
      final groupId = randomGroupId();

      final registerInfo =
          await registerInstance(apiOrigin, instanceId, groupId);

      int successCount = 0;

      // Action
      await scheduleTasks(
        List.filled(100, 0),
        (item, index) async {
          try {
            await fetchInstanceInfo(
              apiOrigin,
              registerInfo.instanceIndex,
              groupId,
            );
            successCount += 1;
          } catch (_) {}
        },
        const Duration(minutes: 2),
      );

      // Assert
      // Ensure about 80 requests are allowed
      expect(successCount, greaterThan(40 * 2));
    },
  );

  test(
    'The tunnel service should correctly enforce rate limiting: 40 requests per minute',
    tags: ['slow'],
    timeout: const Timeout(Duration(seconds: 130)),
    () async {
      // Arrange
      final uri = Uri.parse(instanceInfos.first.tunnelApiUrl);
      final closedCompleters = <Completer<void>>[];

      final clients = createClients(uri, closedCompleters, 100);

      // Action
      await submitTunnelRequests(
        clients,
        instanceInfos.first.instanceIndex,
        const Duration(minutes: 2),
      );

      // Wait until all clients are closed.
      await waitForAllCompleted(closedCompleters);

      // Assert
      final count = countClientsByCloseCodes(
        clients,
        [ChannelCloseCode.authenticationError],
      );

      // Ensure about 80 requests are allowed
      expect(count, closeTo(80, 5));
    },
  );

  test(
    'Both tunnel servers should correctly enforce rate limiting simultaneously',
    tags: ['slow'],
    timeout: const Timeout(Duration(seconds: 150)),
    () async {
      // Arrange
      final uri = [
        Uri.parse(instanceInfos[0].tunnelApiUrl),
        Uri.parse(instanceInfos[1].tunnelApiUrl),
      ];

      // Create clients for both tunnel servers
      final closedCompleters = [
        <Completer<void>>[],
        <Completer<void>>[],
      ];

      final clients = [
        createClients(uri[0], closedCompleters[0], 100),
        createClients(uri[1], closedCompleters[1], 100),
      ];

      // Action: submit requests to both servers
      await Future.wait([
        submitTunnelRequests(
          clients[0],
          instanceInfos[0].instanceIndex,
          const Duration(minutes: 2),
        ),
        submitTunnelRequests(
          clients[1],
          instanceInfos[1].instanceIndex,
          const Duration(minutes: 2),
        ),
      ]);

      // Wait until all clients are closed.
      await waitForAllCompleted(closedCompleters[0]);
      await waitForAllCompleted(closedCompleters[1]);

      // Assert
      final count1 = countClientsByCloseCodes(
        clients[0],
        [ChannelCloseCode.authenticationError],
      );
      final count2 = countClientsByCloseCodes(
        clients[1],
        [ChannelCloseCode.authenticationError],
      );

      // Ensure each server handled requests correctly
      expect(count1, closeTo(80, 5));
      expect(count2, closeTo(80, 5));
    },
  );
}
