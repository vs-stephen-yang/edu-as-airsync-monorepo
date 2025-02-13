import 'dart:io';

import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/rate_limit/rate_limiter.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/webtransport_certificate.dart';
import 'package:display_channel/src/server/direct/webtransport_connection_server.dart';
import 'package:flutter_golang_server/flutter_webtransport.dart';
import 'package:flutter_golang_server/flutter_webtransport_config.dart';
import 'package:flutter_golang_server/flutter_webtransport_listener.dart';

class WebTransportDirectServer implements FlutterWebtransportListener {
  late ChannelStore _store;
  WebTransportConnectionServer? _connectionServer;
  late Future<WebTransportCertificate?> Function() _getWebTransportCertificateCallback;
  final _webTransportServer = FlutterWebtransport();
  late RateLimiter _rateLimiter;

  late Duration _idleConnectionTimeout;

  WebTransportDirectServer(
    Future<WebTransportCertificate?> Function() getWebTransportCertificateCallback,
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest, {
    int maxBurstyRequests = 5,
    double requestsPerSecond = 5,
    Duration heartbeatInterval = const Duration(seconds: 10),
    Duration heartbeatTimeout = const Duration(seconds: 10),
    Duration reconnectTimeout = const Duration(seconds: 2),
  }) {
    _getWebTransportCertificateCallback = getWebTransportCertificateCallback;
    _store = ChannelStore(
      onNewChannel,
      verifyConnectRequest,
      heartbeatInterval: heartbeatInterval,
      heartbeatTimeout: heartbeatTimeout,
      reconnectTimeout: reconnectTimeout,
    );
    _rateLimiter = RateLimiter(
      maxBurstyRequests,
      requestsPerSecond,
    );
    _idleConnectionTimeout = heartbeatInterval + heartbeatTimeout;
    _webTransportServer.registerListener(this);
  }

  Future<void> start(
    int port, {
    required List<String> certPem,
    required List<String> keyPem,
  }) async {
    // direct server
    _connectionServer = WebTransportConnectionServer(
      _webTransportServer,
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

    final config = FlutterWebtransportConfig(
        port: port, cert: certPem, key: keyPem, allowOrigins: []);

    await _webTransportServer.startWebtransportServer(config);

    // rate limiter
    _rateLimiter.start();
  }

  void stop() {
    _rateLimiter.stop();

    _webTransportServer.stopServer();
  }

  @override
  void onConnect(String connId, String queryStr, String clientIp) {
    _connectionServer?.onConnect(connId, queryStr, clientIp);
  }

  @override
  void onClose(String connId) {
    _connectionServer?.onClose(connId);
  }

  @override
  void onMessage(String connId, String message) {
    _connectionServer?.onMessage(connId, message);
  }

  @override
  Future<void> onRequestCertificate() async {
    final certificate = await _getWebTransportCertificateCallback();
    if (certificate == null) {
      return;
    }

    final config = FlutterWebtransportConfig(
        cert: certificate.certPem,
        key: certificate.keyPem
    );
    await _webTransportServer.updateCertificate(config);
  }
}
