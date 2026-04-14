import 'dart:async';
import 'dart:io';
import 'package:display_channel/src/util/api_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_util.dart';
import 'tunnel_test_util.dart';

void main() {
  final apiOrigin = getApiOriginFromEnv();

  const instanceId = 'test-2418f2a0-6e8b-4867-8a50-7f49ec04b885';
  const instanceGroupId = 1;

  Future<RegisterInstanceResult> registerServer() async {
    return registerInstance(apiOrigin, instanceId, instanceGroupId);
  }

  Future<WebSocket> createWsAsServer(String tunnelUrl) {
    return createWebSocketAsServer(tunnelUrl, instanceId);
  }

  group('Establish connection to the Tunnel service', () {
    late RegisterInstanceResult instanceResult;

    setUp(() {
      return Future(() async {
        instanceResult = await registerServer();
      });
    });

    test(
      'should successfully establish a connection as the server',
      tags: ['slow'],
      () async {
        // arrange

        // action
        await createWsAsServer(instanceResult.tunnelApiUrl);

        // assert
      },
    );

    test(
      'should successfully establish a connection as the client',
      tags: ['slow'],
      () async {
        // arrange
        TunnelServer(
          await createWsAsServer(instanceResult.tunnelApiUrl),
          (conneciton) {},
        );

        // action
        await createWebSocketAsClient(
          instanceResult.tunnelApiUrl,
          instanceResult.instanceIndex,
          instanceGroupId,
          '1000',
        );

        // assert
      },
    );

    test(
      'should successfully establish connections for multiple clients',
      tags: ['slow'],
      () async {
        // arrange
        TunnelServer(
          await createWsAsServer(instanceResult.tunnelApiUrl),
          (conneciton) {},
        );

        // action
        for (var i = 0; i < 10; i++) {
          await createWebSocketAsClient(
            instanceResult.tunnelApiUrl,
            instanceResult.instanceIndex,
            instanceGroupId,
            'client-$i',
          );
        }

        // assert
      },
    );
  });

  group('Exchange messages via tunnel service', () {
    late Completer clientConnected;

    late TunnelConnection connection;

    late Client client;

    late RegisterInstanceResult instanceResult;

    setUp(() {
      return Future(() async {
        instanceResult = await registerServer();

        clientConnected = Completer();

        // Server
        TunnelServer(
            await createWebSocketAsServer(
              instanceResult.tunnelApiUrl,
              instanceId,
            ), (TunnelConnection c) {
          clientConnected.complete();
          connection = c;
        });

        // Client
        client = Client(await createWebSocketAsClient(
          instanceResult.tunnelApiUrl,
          instanceResult.instanceIndex,
          instanceGroupId,
          '1000',
        ));

        await clientConnected.future;
      });
    });

    test(
      'Ensures 200 messages are reliably delivered from client to server with delay',
      tags: ['slow'],
      () async {
        // arrange
        final counter = CounterCondition(200);
        connection.receivedCounter = counter;

        // action
        await client.sendMessages(count: 200, delayMs: 100);

        await counter.wait();

        // assert
        expect(countUniqueMessages(connection.messages), 200);
      },
    );

    test(
      'Ensures 200 messages are reliably delivered from server to client with delay',
      tags: ['slow'],
      () async {
        // arrange
        final counter = CounterCondition(200);
        client.receivedCounter = counter;

        // action
        await connection.sendMessages(count: 200, delayMs: 100);

        counter.wait();

        // assert
        expect(countUniqueMessages(client.messages), 200);
      },
    );
    test(
      'Ensures 100 consecutive messages are reliably delivered from client to server with no delay',
      tags: ['slow'],
      () async {
        // arrange
        final counter = CounterCondition(100);
        connection.receivedCounter = counter;

        // action
        await client.sendMessages(count: 100, delayMs: 0);

        await counter.wait();

        // assert
        expect(countUniqueMessages(connection.messages), 100);
      },
    );

    test(
      'Ensures 100 consecutive messages are reliably delivered from server to client with no delay',
      tags: ['slow'],
      () async {
        // arrange
        final counter = CounterCondition(100);
        client.receivedCounter = counter;

        // action
        await connection.sendMessages(count: 100, delayMs: 0);

        await counter.wait();

        // assert
        expect(countUniqueMessages(client.messages), 100);
      },
    );
  });
}
