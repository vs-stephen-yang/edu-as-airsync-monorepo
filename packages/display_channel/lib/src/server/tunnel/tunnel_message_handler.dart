import 'package:display_channel/src/server/tunnel/tunnel_message.dart';

class TunnelMessageHandler {
  void onClientConnected(TunnelClientConnected msg) {}

  void onClientDisconnected(TunnelClientDisconnected msg) {}

  void onDisconnectClient(TunnelDisconnectClient msg) {}

  void onClientMsg(TunnelClientMsg msg) {}

  void onHeartbeat(TunnelHeartbeatMessage msg) {}
}
