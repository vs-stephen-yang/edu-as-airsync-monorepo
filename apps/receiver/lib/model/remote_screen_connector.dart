
import 'package:display_channel/display_channel.dart';

class RemoteScreenConnector {
  String roomId = 'remote-screen';
  String? host;
  int port;
  Channel channel;
  String? _sessionId;

  RemoteScreenConnector(this.channel, this.host, this.port);

  onStartRemoteScreen(StartRemoteScreenMessage message) {
    final remoteScreenInfoMessage = RemoteScreenInfoMessage(
      _sessionId = message.sessionId,
      IonSfuRoom(
        "ws://$host:$port/ws",
        roomId,
      ),);
    channel.send(remoteScreenInfoMessage);
  }

}