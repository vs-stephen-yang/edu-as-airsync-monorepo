import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'test_config.dart';
import 'test_util.dart';
import 'tunnel_test_util.dart';

Future<WebSocket> _createWsAsServer() {
  return createWebSocketAsServer(tunnelServiceUrl, instanceId);
}

void main() {
  group('Establish connection to the Tunnel service', skip: true, () {
    test(
      'should successfully establish a connection as the server',
      () async {
        // arrange
        final stopwatch = Stopwatch();

        // action
        stopwatch.start();
        await _createWsAsServer();
        stopwatch.stop();

        // assert
        final latency = stopwatch.elapsedMilliseconds;
        expect(latency, lessThan(5000), reason: 'Operation took too long');
      },
    );

    test(
      'should successfully establish a connection as the client',
      () async {
        // arrange
        TunnelServer(
          await _createWsAsServer(),
          (conneciton) {},
        );

        final stopwatch = Stopwatch();

        // action
        stopwatch.start();

        await createWebSocketAsClient(
          tunnelServiceUrl,
          instanceIndex,
          groupId,
          '1000',
        );
        stopwatch.stop();

        // assert
        final latency = stopwatch.elapsedMilliseconds;
        expect(latency, lessThan(1000),
            reason: 'Client connection took too long');
      },
    );

    test(
      'should successfully establish connections for multiple clients',
      () async {
        // arrange
        TunnelServer(
          await _createWsAsServer(),
          (conneciton) {},
        );
        final stopwatches = <Stopwatch>[];

        // action
        for (var i = 0; i < 10; i++) {
          final stopwatch = Stopwatch();
          stopwatches.add(stopwatch);

          stopwatch.start();

          await createWebSocketAsClient(
            tunnelServiceUrl,
            instanceIndex,
            groupId,
            'client-$i',
          );
          stopwatch.stop();

          await Future.delayed(const Duration(milliseconds: 100));
        }

        // assert
        for (var i = 0; i < stopwatches.length; i++) {
          final latency = stopwatches[i].elapsedMilliseconds;

          expect(latency, lessThan(1000),
              reason: 'Client $i connection took too long');
        }
      },
    );
  });

  group('Exchange messages between client and server', skip: true, () {
    late Completer clientConnected;

    late TunnelConnection connection;

    late Client client;

    setUp(() {
      return Future(() async {
        clientConnected = Completer();

        // Server
        TunnelServer(
            await createWebSocketAsServer(
              tunnelServiceUrl,
              instanceId,
            ), (TunnelConnection c) {
          clientConnected.complete();
          connection = c;
        });

        // Client
        client = Client(await createWebSocketAsClient(
          tunnelServiceUrl,
          instanceIndex,
          groupId,
          '1000',
        ));

        await clientConnected.future;
      });
    });

    test(
      'Ensures 200 messages are reliably delivered from client to server with delay',
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

  group('Multiple clients exchange messages with multiple tunnel servers',
      skip: true, () {
    test(
      'should successfully establish a connection as the server',
      () async {
        // arrange
        final stopwatch = Stopwatch();

        // action
        stopwatch.start();
        await _createWsAsServer();
        stopwatch.stop();

        // assert
        final latency = stopwatch.elapsedMilliseconds;
        expect(latency, lessThan(5000), reason: 'Operation took too long');
      },
    );
  });
}
