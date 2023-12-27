import "dart:convert";

import "package:display_channel/src/client_connection.dart";
import "package:universal_html/html.dart";

class WebSocketClientConnection implements ClientConnection {
  @override
  void Function()? onConnected;

  @override
  void Function(ConnectError error)? onConnectFailed;

  @override
  void Function()? onConnecting;

  @override
  void Function()? onDisconnected;

  @override
  void Function(Map<String, dynamic> data)? onMessage;

  final String _url;

  var _connected = false;
  var _closed = false;

  void Function(String url, String message)? logger;

  WebSocket? _socket;

  WebSocketClientConnection(
    this._url, {
    this.logger,
  });

  @override
  void open() {
    _connect();
  }

  @override
  Future<void> close() async {
    _closed = true;

    _closeSocket();
  }

  void _connect() async {
    if (_closed) {
      return;
    }

    logger?.call(_url, "connect");
    onConnecting?.call();

    _socket = WebSocket(
      _url,
    );

    _socket?.onOpen.listen((Event e) {
      _connected = true;
      onConnected?.call();
    });

    _socket?.onClose.listen((CloseEvent e) {
      final lastConnected = _connected;

      _connected = false;

      //TODO: add retry
      if (lastConnected) {
        onDisconnected?.call();
      } else {
        onConnectFailed?.call(
          ConnectError(
            ConnectErrorType.websocket,
            "code=${e.code} reason=${e.reason}",
          ),
        );
      }
    });

    _socket?.onMessage.listen((MessageEvent e) {
      final message = jsonDecode(e.data);
      onMessage?.call(message);
    });
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _socket?.send(data);
  }

  _closeSocket() {
    _socket?.close();
    _socket = null;
  }
}
