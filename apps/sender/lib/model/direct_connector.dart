
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_channel/display_channel.dart';

class DirectConnector {

  final String _clientId;

  final String? _displayCode;

  final String? _otp;

  DisplayChannelClient? _directClient;

  final _directPendingMessages = <ChannelMessage>[];

  final void Function(Channel channel) _onOpened;
  final void Function(ChannelConnectorError error) _onOpenError;

  DirectConnector({
    required String clientId,
    required String? displayCode,
    required String? otp,
    required void Function(Channel channel) onOpened,
    required void Function(ChannelConnectorError error) onOpenError,
  })  : _clientId = clientId,
        _displayCode = displayCode,
        _otp = otp,
        _onOpened = onOpened,
        _onOpenError = onOpenError;

  open({
    required AirSyncBonsoirService service
  }) {

    // open direct channel
    final uri = Uri(
      scheme: 'wss',
      host: service.ip,
      port: service.port,
    );

    _directClient = DisplayChannelClient(
        _clientId,
        uri,
            (url) => WebSocketClientConnection(url,
            maxRetryDelay: const Duration(seconds: 3),
            maxRetryAttempts: 3,
            logger: (url, message) =>
                print('_directClient logger $url $message}'),
            allowSelfSignedCertificates: true));
    _directClient?.openDirectChannel(token: _otp, displayCode: _displayCode);
    _directClient?.onStateChange = (ChannelState state) {

      if (state == ChannelState.connected) {
        _onOpened(_directClient!);

        drainPendingMessages(_directClient!, _directPendingMessages);

      } else if (state == ChannelState.closed) {
        final error = mapCloseCodeToChannelConnectorError(
          _directClient?.closeReason?.code,
        );
        _onOpenError(error);
      }
    };
  }

  drainPendingMessages(
      DisplayChannelClient client,
      List<ChannelMessage> messages,
      ) {
    // Note: messages may arrive early before the state of the channel switches to connected
    for (var message in messages) {
      client.onChannelMessage?.call(message);
    }

    messages.clear();
  }
}