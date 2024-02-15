import 'dart:io';

import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/direct/direct_connection_server.dart';

class DisplayDirectServer {
  final ChannelStore _store;
  DirectConnectionServer? _directServer;
  HttpServer? _httpServer;

  int? get port {
    return _httpServer?.port;
  }

  DisplayDirectServer(
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest,
  ) : _store = ChannelStore(
          onNewChannel,
          verifyConnectRequest,
        );

  Future<void> start(int port) async {
    // direct server
    _directServer = DirectConnectionServer(
        (String clientId, Connection connection) =>
            _store.handleNewConnection(clientId, connection),
        (ConnectionRequest connectionRequest) =>
            _store.verifyConnectionRequest(connectionRequest));

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
  }

  void stop() {
    _httpServer?.close();
  }
}
