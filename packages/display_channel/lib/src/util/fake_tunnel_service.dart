import 'dart:convert';
import 'dart:io';

import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_handler.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_parser.dart';

class MsgHandler implements TunnelMessageHandler {
  final FakeTunnelService _svc;
  final int _connectionId;

  MsgHandler(this._svc, this._connectionId);

  @override
  void onClientConnected(TunnelClientConnected msg) {}

  @override
  void onClientDisconnected(TunnelClientDisconnected msg) {}

  @override
  void onClientMsg(TunnelClientMsg msg) {
    _svc.onClientMsg(_connectionId, msg);
  }

  @override
  void onDisconnectClient(TunnelDisconnectClient msg) {
    _svc.onDisconnectClient(_connectionId, msg);
  }

  @override
  void onHeartbeat(TunnelHeartbeatMessage msg) {}
}

class FakeTunnelService {
  var _lastConnectionId = 0;

  // TODO:
  final String _instanceIndex;

  final _serverConnections = <int, WebSocket>{};
  final _clientConnections = <int, WebSocket>{};

  FakeTunnelService({
    required String instanceIndex,
  }) : _instanceIndex = instanceIndex;

  Future onHttpRequest(HttpRequest httpRequest) async {
    final parameters = httpRequest.requestedUri.queryParameters;

    final role = parameters['role'];

    _lastConnectionId += 1;
    final connectionId = _lastConnectionId;

    if (role == 'server') {
      await _onServerConnected(connectionId, httpRequest, parameters);
    } else if (role == 'client') {
      await _onClientConnected(connectionId, httpRequest, parameters);
    }
  }

// handle the connection from the server
  Future _onServerConnected(
    int connectionId,
    HttpRequest httpRequest,
    Map<String, String> parameters,
  ) async {
    final websocket = await WebSocketTransformer.upgrade(httpRequest);

    _serverConnections[connectionId] = websocket;

    websocket.listen((dynamic data) {
      // receive data from the server
      final message = jsonDecode(data);
      _onDataFromServer(connectionId, message);
    }, onDone: () {
      // websocket connection closed
      _serverConnections.remove(connectionId);
    }, onError: (error) {
      // websocket connection error
      _serverConnections.remove(connectionId);
    }, cancelOnError: true);
  }

  bool _isServerOnline(String instanceIndex) {
    return instanceIndex == _instanceIndex && _serverConnections.isNotEmpty;
  }

  // handle the connection from the client
  Future _onClientConnected(
    int connectionId,
    HttpRequest httpRequest,
    Map<String, String> parameters,
  ) async {
    final instanceIndex = parameters['instanceIndex'] as String;

    if (!_isServerOnline(instanceIndex)) {
      await httpRequest.response.close();
      return;
    }
    final websocket = await WebSocketTransformer.upgrade(httpRequest);

    _clientConnections[connectionId] = websocket;

    websocket.listen((dynamic data) {
      // receive data from the client
      final message = jsonDecode(data);
      _onDataFromClient(connectionId, message);
    }, onDone: () {
      // websocket connection closed
      _onClientClosed(connectionId);
    }, onError: (error) {
      // websocket connection error
      _onClientClosed(connectionId);
    }, cancelOnError: true);

    final clientId = parameters['clientId'];
    final token = parameters['token'];
    final displayCode = parameters['displayCode'];

    _notifyClientConnected(
      clientId!,
      connectionId.toString(),
      displayCode!,
      token!,
    );
  }

  void _onClientClosed(int connectionId) {
    _clientConnections.remove(connectionId);

    final msg = TunnelClientDisconnected(connectionId.toString());

    _sendToServer(msg);
  }

  void _sendToServer(TunnelMessage msg) {
    for (var cid in _serverConnections.keys) {
      _serverConnections[cid]?.add(jsonEncode(msg.toJson()));
    }
  }

  void _notifyClientConnected(
    String clientId,
    String connectionId,
    String displayCode,
    String token,
  ) {
    final msg = TunnelClientConnected(
      connectionId,
      clientId,
      token,
      displayCode,
    );

    _sendToServer(msg);
  }

  void _notifyClientDisconnected(String connectionId) {
    final msg = TunnelClientDisconnected(connectionId);

    _sendToServer(msg);
  }

// forward data to the client
  void _forwardDataToClient(String connectionId, Map<String, dynamic> data) {
    final client = _clientConnections[int.parse(connectionId)];

    client?.add(jsonEncode(data));
  }

  //forward data to the server
  void _forwardDataToServer(int connectionId, Map<String, dynamic> data) {
    final msg = TunnelClientMsg(connectionId.toString(), data);

    _sendToServer(msg);
  }

  void _onDataFromClient(int connectionId, Map<String, dynamic> data) {
    _forwardDataToServer(connectionId, data);
  }

  void _onDataFromServer(int connectionId, Map<String, dynamic> data) {
    final parser = TunnelMessageParser(MsgHandler(this, connectionId));

    parser.parse(data);
  }

  void onClientMsg(int serverConnectionId, TunnelClientMsg msg) {
    _forwardDataToClient(msg.connectionId, msg.data);
  }

  void onDisconnectClient(int serverConnectionId, TunnelDisconnectClient msg) {}
}
