import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/settings/channel_config.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_channel/display_channel.dart';

class DirectConnector {
  final String _clientId;

  final String? _displayCode;

  final String? _otp;

  DisplayChannelClient? _directClient;

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
    required AirSyncBonsoirService service,
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
      (url, bool isReconnect) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          retry: getChannelRetryConfig(isReconnect),
          logger: (url, message) =>
              log.fine('_directClient logger $url $message}'),
          allowSelfSignedCertificates: true,
        ),
      ),
    );

    _directClient?.openDirectChannel(token: _otp, displayCode: _displayCode);
    _directClient?.stateController.stream.listen((ChannelState state) {
      if (state == ChannelState.connected) {
        _onOpened(_directClient!);
      } else if (state == ChannelState.closed) {
        final error = mapCloseCodeToChannelConnectorError(
          _directClient?.closeReason?.code,
        );
        _onOpenError(error);
      }
    });
  }
}
