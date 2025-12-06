import 'dart:io';

import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/rate_limit/rate_limiter.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/direct/direct_connection_server.dart';
import 'package:display_channel/src/util/log.dart';

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

    _httpServer!.listen(
      (request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          await _directServer!.onHttpRequest(request);
        }
      },
      onError: (error, stackTrace) {
        if (error is SocketException && isExpectedSocketError(error)) {
          return; // Ignore expected network reset errors
        }

        // Handle unexpected errors only
        log().severe('Unexpected HttpServer error', error, stackTrace);
      },
      // Do not stop the HttpServer on stream errors; keep accepting new connections
      cancelOnError: false,
    );

    // rate limiter
    _rateLimiter.start();
  }

  void stop() {
    _rateLimiter.stop();

    _httpServer?.close();
  }

  bool isExpectedSocketError(SocketException e) {
    final code = e.osError?.errorCode;

    // Expected and ignorable socket errors:
    // - ECONNRESET (Linux/Android = 104, Windows = 10054)
    // - EPIPE (Broken pipe = 32)
    return code == 104 || // Linux / Android: ECONNRESET
        code == 10054 || // Windows: ECONNRESET
        code == 32; // EPIPE (Broken pipe)
  }
}
