import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_handler.dart';

class TunnelMessageParser {
  final TunnelMessageHandler _handler;

  TunnelMessageParser(this._handler);

  bool parse(Map<String, dynamic> msg) {
    final action = msg['action'];
    switch (action) {
      case 'connected':
        _handler.onClientConnected(TunnelClientConnected.fromJson(msg));
        break;
      case 'disconnected':
        _handler.onClientDisconnected(TunnelClientDisconnected.fromJson(msg));
        break;
      case 'disconnect':
        _handler.onDisconnectClient(TunnelDisconnectClient(
          msg['connectionId'],
          DisconnectReason(
            null,
            '',
          ),
        ));
        break;
      case 'msg':
        _handler.onClientMsg(TunnelClientMsg.fromJson(msg));
        break;
      case 'heartbeat':
        _handler.onHeartbeat(TunnelHeartbeatMessage.fromJson(msg));
        break;
    }
    return true;
  }
}
