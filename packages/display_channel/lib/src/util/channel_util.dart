import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';

ChannelCloseCode connectErrorToChannelCloseCode(ConnectErrorType error) {
  switch (error) {
    case ConnectErrorType.websocket:
      return ChannelCloseCode.instanceNotFound;
    default:
      return ChannelCloseCode.networkError;
  }
}
