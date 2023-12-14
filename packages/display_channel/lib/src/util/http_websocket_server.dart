import 'dart:io';

class HttpWebSocketServer {
  HttpServer? _httpServer;

  final void Function(WebSocket ws, HttpRequest req) _handler;

  HttpWebSocketServer(this._handler);

  int? get port => _httpServer?.port;

  Future<void> start(int port) async {
    _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, port);

    _httpServer!.listen((request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        var websocket = await WebSocketTransformer.upgrade(request);
        _handler(websocket, request);
      } else {
        // Do normal HTTP request processing.
      }
    });
  }

  void close() {
    _httpServer?.close();
  }
}
