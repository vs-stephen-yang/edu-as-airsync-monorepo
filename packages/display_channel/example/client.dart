import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/log.dart';
import 'package:uuid/uuid.dart';

class Client {
  final Channel _channel;

  final String _clientId;
  final _sessionId = const Uuid().v4();

  Client(this._clientId, this._channel) {
    _channel.stateController.stream.listen((ChannelState state) {
      switch (state) {
        case ChannelState.connecting:
          log().info('The client is connecting to the display');
          break;
        case ChannelState.connected:
          log().info('The client has connected to the display');
          break;
        case ChannelState.closed:
          log().info(
              'The client has closed. Reason: ${_channel.closeReason?.code}');
          log().info('${_channel.closeReason?.text}');
          break;
        default:
          break;
      }
    });

    _channel.onChannelMessage = (message) {
      log().info('Received ${message.messageType}');

      switch (message.messageType) {
        case ChannelMessageType.displayStatus:
          _onDisplayStatus(message as DisplayStatusMessage);
          break;
        default:
          break;
      }
    };
  }

  void _onDisplayStatus(DisplayStatusMessage message) {
    _joinDisplay();
    _startPresent();

    _presentSignal(SignalMessageType.offer);

    for (int i = 0; i < 5; i++) {
      _presentSignal(SignalMessageType.candidate);
    }
  }

  void _joinDisplay() {
    final msg = JoinDisplayMessage(_clientId);
    _channel.send(msg);
  }

  void _startPresent() {
    final msg = StartPresentMessage(_sessionId);
    _channel.send(msg);
  }

  void _presentSignal(SignalMessageType signalType) {
    final msg = PresentSignalMessage(_sessionId, signalType);
    _channel.send(msg);
  }
}
