import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'package:display_channel/src/util/log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'test_util.dart';

/// Creates and returns a DisplayTunnelServer instance.
DisplayTunnelServer createTunnelServer() {
  return DisplayTunnelServer(
    (String url, bool _) => WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        logger: (String url, String message) {
          //log().info('$url $message');
        },
      ),
    ),
    (channel, queryParameters) {
      channel.messageStream.listen((message) {
        // Echo the received message back to the client.
        final request = message as JoinDisplayMessage;
        final reply = JoinDisplayMessage(request.clientId);
        reply.name = request.name;

        channel.send(reply);
      });
    },
    (connectRequest) => ConnectRequestStatus.success,
  );
}

/// Creates a WebSocketClientConnection with specific configuration.
WebSocketClientConnection createConnectionTunnel(url, bool isReconnect) =>
    WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        retry: const RetryConfig(
          maxRetryDelay: Duration(seconds: 1),
          maxRetryAttempts: 4,
        ),
        //logger: (url, message) => log().info('$url $message'),
        allowSelfSignedCertificates: false,
      ),
    );

/// Represents an instance with related information for tunneling.
class InstanceItem {
  final String instanceId;
  final int groupId;

  int? instanceIndex;
  String? tunnelUrl;
  bool isFirstConnected = false;
  DisplayTunnelServer? server;

  InstanceItem(this.instanceId, this.groupId);
}

/// Represents a client with related information for tunneling.
class ClientItem {
  final int instanceIndex;
  final int groupId;
  final String tunnelUrl;

  bool isFirstConnected = false;
  late CounterCondition messageReceivedCounter;
  final messagesReceived = <int>[];

  ClientItem(
    this.instanceIndex,
    this.groupId,
    this.tunnelUrl,
    int messageCount,
  ) {
    messageReceivedCounter = CounterCondition(messageCount);
  }
}

void main() {
  final apiOrigin = getApiOriginFromEnv();

  const totalInstanceCount = 100;
  const instanceDuration = Duration(seconds: 120);

  const clientsPerInstance = 2;

  const clientDuration = Duration(seconds: 200);

  const messagesPerClient = 10;

  // Main test that simulates connection of multiple instances and clients.
  test(
    'Simulate Multiple Instance and Client Connections Over Time',
    tags: ['slow'],
    timeout: const Timeout(Duration(minutes: 10)),
    () async {
      final instanceItems = <InstanceItem>[];
      final clientItems = <ClientItem>[];

      // Create instances
      for (var i = 0; i < totalInstanceCount; i++) {
        final instanceId = const Uuid().v4();
        final groupId = randomGroupId();

        instanceItems.add(InstanceItem(instanceId, groupId));
      }

      final instanceConnectedCounter = CounterCondition(instanceItems.length);

      /// Task to register an instance and start its tunnel server.
      Future<void> instanceTask(InstanceItem instanceItem, int index) async {
        final result = await registerInstance(
            apiOrigin, instanceItem.instanceId, instanceItem.groupId);

        instanceItem.tunnelUrl = result.tunnelApiUrl;
        instanceItem.instanceIndex = result.instanceIndex;

        final server = createTunnelServer();

        server.onTunnelConnected = () {
          log().fine('Instance $index connected');
          instanceConnectedCounter();
          instanceItem.isFirstConnected = true;
        };

        server.onTunnelConnecting = () {
          log().fine('Instance $index connecting');
        };

        server.start(
          instanceItem.instanceId,
          instanceItem.groupId,
          Uri.parse(result.tunnelApiUrl),
        );
      }

      // Schedule the instance tasks to run
      await scheduleTasks(
        instanceItems,
        (instanceItem, index) async {
          await instanceTask(instanceItem, index);
        },
        instanceDuration,
      );

      // Wait for all instances to connect.
      await instanceConnectedCounter.wait();

      // Create multiple clients for each instance.
      for (var i = 0; i < instanceItems.length; i++) {
        final instanceItem = instanceItems[i];

        for (var j = 0; j < clientsPerInstance; j++) {
          clientItems.add(
            ClientItem(
              instanceItem.instanceIndex!,
              instanceItem.groupId,
              instanceItem.tunnelUrl!,
              messagesPerClient,
            ),
          );
        }
      }

      /// Task to manage client connections.
      Future<void> clientTask(ClientItem clientItem, int clientIndex) async {
        final clientId = '$clientIndex';
        final client = DisplayChannelClient(
          clientId,
          Uri.parse(clientItem.tunnelUrl),
          createConnectionTunnel,
        );

        // Open the client's tunnel channel.
        client.openTunnelChannel(
          clientItem.instanceIndex,
          clientItem.groupId,
          '0000',
          displayCode: '12345',
        );

        /// Task to send a message.
        Future<void> deliverMessageTask(String _, int index) async {
          final message = JoinDisplayMessage(clientId);
          message.name = index.toString();
          log().fine('client $clientIndex send');

          client.send(message);
        }

        // Handle incoming messages from the server.
        client.messageStream.listen((message) {
          final joinDisplayMessage = message as JoinDisplayMessage;
          log().fine('client $clientIndex ${joinDisplayMessage.name}');

          clientItem.messageReceivedCounter();
          clientItem.messagesReceived.add(int.parse(joinDisplayMessage.name!));
        });

        // Handle state changes for the client.
        client.stateStream.listen((ChannelState state) {
          if (state == ChannelState.connected) {
            log().fine('client $clientIndex connected');

            if (!clientItem.isFirstConnected) {
              // Schedule message delivery tasks if it's the first connection.
              scheduleTasks(
                List<String>.filled(messagesPerClient, ''),
                deliverMessageTask,
                const Duration(seconds: 20),
              );
              clientItem.isFirstConnected = true;
            }
          } else if (state == ChannelState.closed) {
            log().fine('client $clientIndex closed');
          }
        });
      }

      // Schedule the client tasks to run with a 2-minute interval.
      await scheduleTasks(
        clientItems,
        (clientItem, index) async {
          await clientTask(clientItem, index);
        },
        clientDuration,
      );

      // Wait for all clients to receive their messages.
      await Future.wait(clientItems
          .map(
            (e) => e.messageReceivedCounter.future,
          )
          .toList());

      // Assert: Check that all instances have connected at least once.
      expect(
        instanceItems.every((instance) => instance.isFirstConnected),
        isTrue,
        reason: 'All instances should have isFirstConnected set to true',
      );

      // Assert: Check that all clients have connected at least once.
      expect(
        clientItems.every((client) => client.isFirstConnected),
        isTrue,
        reason: 'All clients should have isFirstConnected set to true',
      );

      expect(
        clientItems.every((client) =>
            client.messagesReceived.toSet().toList().length ==
            messagesPerClient),
        isTrue,
        reason: 'All clients should have isFirstConnected set to true',
      );
    },
  );
}
