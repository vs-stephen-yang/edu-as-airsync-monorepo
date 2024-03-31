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

  final Duration _idleConnectionTimeout;

  int? get port {
    return _httpServer?.port;
  }

  DisplayDirectServer(
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest, {
    int maxBurstyRequests = 5,
    double requestsPerSecond = 5,
    Duration heartbeatInterval = const Duration(seconds: 10),
    Duration heartbeatTimeout = const Duration(seconds: 10),
    Duration reconnectTimeout = const Duration(seconds: 2),
  })  : _store = ChannelStore(
          onNewChannel,
          verifyConnectRequest,
          heartbeatInterval: heartbeatInterval,
          heartbeatTimeout: heartbeatTimeout,
          reconnectTimeout: reconnectTimeout,
        ),
        _rateLimiter = RateLimiter(
          maxBurstyRequests,
          requestsPerSecond,
        ),
        _idleConnectionTimeout = heartbeatInterval + heartbeatTimeout;

  Future<void> start(
    int port, {
    SecurityContext? securityContext,
  }) async {
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
      idleConnectionTimeout: _idleConnectionTimeout,
    );

    // HTTP server
    if (securityContext != null) {
      // https
      _httpServer = await HttpServer.bindSecure(
        InternetAddress.anyIPv4,
        port,
        securityContext,
        // https://blog.csdn.net/Lumend/article/details/115865931
        shared: true,
      );
    } else {
      // http
      _httpServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        // https://blog.csdn.net/Lumend/article/details/115865931
        shared: true,
      );
    }

    _httpServer!.listen((request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        await _directServer!.onHttpRequest(request);
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
