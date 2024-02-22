import 'dart:io';

import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/rate_limit/rate_limiter.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/direct/direct_connection_server.dart';

class DisplayDirectServer {
  final ChannelStore _store;
  DirectConnectionServer? _directServer;
  HttpServer? _httpServer;
  final RateLimiter _rateLimiter;

  int? get port {
    return _httpServer?.port;
  }

  DisplayDirectServer(
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest, {
    int maxBurstyRequests = 5,
    double requestsPerSecond = 5,
  })  : _store = ChannelStore(
          onNewChannel,
          verifyConnectRequest,
        ),
        _rateLimiter = RateLimiter(
          maxBurstyRequests,
          requestsPerSecond,
        );

  Future<void> start(int port) async {
    // direct server
    _directServer = DirectConnectionServer(
      (String clientId, Connection connection) {
        _store.handleNewConnection(clientId, connection);
      },
      (ConnectionRequest connectionRequest) {
        // Apply rate limiting to connection requests.
        if (connectionRequest.clientIpAddress != null) {
          if (!_rateLimiter.allowRequest(connectionRequest.clientIpAddress!)) {
            return ConnectRequestStatus.rateLimitExceeded;
          }
        }

        return _store.verifyConnectionRequest(connectionRequest);
      },
    );

    // HTTP server
    _httpServer = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
    );

    _httpServer!.listen((request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        _directServer!.onHttpRequest(request);
      }
    });

    // rate limiter
    _rateLimiter.start();
  }

  void stop() {
    _rateLimiter.stop();

    _httpServer?.close();
  }
}
