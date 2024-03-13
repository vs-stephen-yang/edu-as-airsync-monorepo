import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/display_channel_client.dart';
import 'package:display_channel/src/display_code.dart';
import 'package:display_channel/src/messages/channel_message.dart';

enum FetchChannelTunnelUrlError {
  instanceNotFound,
  networkError,
  unknownError,
}

class FetchChannelTunnelUrlException implements Exception {
  FetchChannelTunnelUrlError error;

  FetchChannelTunnelUrlException(this.error);
}

// throw FetchChannelTunnelUrlException
typedef FetchChannelTunnelUrl = Future<String> Function(int instanceIndex);

enum ChannelConnectorError {
  instanceNotFound,
  authenticationError,
  networkError,
  invalidDisplayCode,
  rateLimitExceeded,
  unknownError,
}

class DisplayChannelConnector {
  final CreateWebsocketClientConnection _createConnectionTunnel;
  final CreateWebsocketClientConnection _createConnectionDirect;
  final FetchChannelTunnelUrl _fetchTunnelUrl;

  final String _clientId;

  final String _encodedDisplayCode;
  final DisplayCode _displayCode;
  final String _otp;

  DisplayChannelClient? _tunnelClient;
  DisplayChannelClient? _directClient;

  bool _connected = false;

  final _directPendingMessages = <ChannelMessage>[];
  final _tunnelPendingMessages = <ChannelMessage>[];

  bool _useDirect = false;
  bool _useTunnel = false;

  bool _directFailed = false;
  bool _tunnelFailed = false;

  FetchChannelTunnelUrlError? _tunnelUrlFetchError;

  final void Function(Channel channel) _onOpened;
  final void Function(ChannelConnectorError error) _onOpenError;

  DisplayChannelConnector({
    required String clientId,
    required String otp,
    required DisplayCode displayCode,
    required String encodedDisplayCode,
    required CreateWebsocketClientConnection createConnectionTunnel,
    required CreateWebsocketClientConnection createConnectionDirect,
    required FetchChannelTunnelUrl fetchTunnelUrl,
    required void Function(Channel channel) onOpened,
    required void Function(ChannelConnectorError error) onOpenError,
  })  : _clientId = clientId,
        _otp = otp,
        _displayCode = displayCode,
        _encodedDisplayCode = encodedDisplayCode,
        _createConnectionTunnel = createConnectionTunnel,
        _createConnectionDirect = createConnectionDirect,
        _fetchTunnelUrl = fetchTunnelUrl,
        _onOpened = onOpened,
        _onOpenError = onOpenError;

  open({
    int? directPort,
  }) {
    // open direct channel
    if (directPort != null) {
      assert(_displayCode.hasIpAddress());

      _useDirect = true;

      _openDirectChannel(
        _displayCode.ipAddress,
        directPort,
      );
    }

    // open tunnel channel
    if (_displayCode.instanceIndex > 0) {
      _useTunnel = true;

      // fetching the tunnel URL
      _fetchTunnelUrl(
        _displayCode.instanceIndex,
      ).then(
        // fetch the tunnel URL successfully
        (String tunnelUrl) {
          _openTunnelChannel(tunnelUrl);
        },
      ).catchError(
        // Failed to fetch the tunnel URL
        (e) {
          _tunnelFailed = true;

          if (e is FetchChannelTunnelUrlException) {
            _tunnelUrlFetchError = e.error;
          } else {
            _tunnelUrlFetchError = FetchChannelTunnelUrlError.unknownError;
          }
          _onConnectFailed();
        },
      );
    }
  }

  // open tunnel channel
  _openTunnelChannel(String tunnelUrl) {
    Uri uri = Uri.parse(tunnelUrl);

    // create a channel client
    _tunnelClient = DisplayChannelClient(
      _clientId,
      uri,
      _createConnectionTunnel,
    );

    // open the client
    _tunnelClient!.openTunnelChannel(
      _displayCode.instanceIndex.toString(),
      _otp,
      displayCode: _encodedDisplayCode,
    );

    _tunnelClient!.onChannelMessage = (message) {
      // store the messages that arrive before the channel becomes connected
      _tunnelPendingMessages.add(message);
    };

    _tunnelClient!.onStateChange = (state) {
      if (state == ChannelState.connected) {
        _onTunnelConnected();
      } else if (state == ChannelState.closed) {
        _tunnelFailed = true;
        _onConnectFailed();
      }
    };
  }

  // open direct channel
  _openDirectChannel(
    String ipAddress,
    int port,
  ) {
    final uri = Uri(
      // TODO: use wss
      scheme: 'ws',
      host: ipAddress,
      port: port,
    );

    // create a channel client
    _directClient = DisplayChannelClient(
      _clientId,
      uri,
      _createConnectionDirect,
    );

    // open the client
    _directClient!.openDirectChannel(
      _otp,
      displayCode: _encodedDisplayCode,
    );

    _directClient!.onChannelMessage = (message) {
      // store the messages that arrive before the channel becomes connected
      _directPendingMessages.add(message);
    };

    _directClient!.onStateChange = (ChannelState state) {
      if (state == ChannelState.connected) {
        _onDirectConnected();
      } else if (state == ChannelState.closed) {
        _directFailed = true;
        _onConnectFailed();
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

  // direct channel is connected
  _onDirectConnected() {
    if (_connected) {
      // Too late. The tunnel channel is alread connected.
      // Close the direct channel
      _directClient?.onStateChange = null;
      _directClient?.close(null);
      return;
    }

    _connected = true;
    _onOpened(_directClient!);

    drainPendingMessages(_directClient!, _directPendingMessages);
  }

  // tunnel channel is connected
  _onTunnelConnected() {
    if (_connected) {
      // Too late. The direct channel is alread connected.
      // Close the tunnel channel
      _tunnelClient?.onStateChange = null;
      _tunnelClient?.close(null);
      return;
    }

    _connected = true;
    _onOpened(_tunnelClient!);

    drainPendingMessages(_tunnelClient!, _tunnelPendingMessages);
  }

  _mapDualConnectError() {
    //tunnel error
    final tunnelError = mapTunnelChannelError(
      _tunnelUrlFetchError,
      _tunnelClient?.closeReason?.code,
    );

    //direct error
    final directError = mapCloseCodeToChannelConnectorError(
      _directClient?.closeReason?.code,
    );

    return mapDualConnectError(
      directError,
      tunnelError,
    );
  }

  _onConnectFailed() {
    if (_useDirect && _useTunnel) {
      // dual connections: direct and tunnel
      if (_directFailed && _tunnelFailed) {
        // both failed
        final error = _mapDualConnectError();
        _onOpenError(error);
      }
    } else {
      // single connection: direct or tunnel
      if (_useTunnel) {
        assert(_tunnelFailed);

        // tunnel
        final error = mapTunnelChannelError(
          _tunnelUrlFetchError,
          _tunnelClient?.closeReason?.code,
        );

        _onOpenError(error);
      } else {
        assert(_directFailed);

        // direct
        final error = mapCloseCodeToChannelConnectorError(
          _directClient?.closeReason?.code,
        );
        _onOpenError(error);
      }
    }
  }
}

ChannelConnectorError mapDualConnectError(
  ChannelConnectorError directError,
  ChannelConnectorError tunnelError,
) {
  if (directError == ChannelConnectorError.networkError &&
      tunnelError == ChannelConnectorError.networkError) {
    // both are network error
    return ChannelConnectorError.networkError;
  } else {
    // one is network error
    if (directError == ChannelConnectorError.networkError) {
      return tunnelError;
    } else {
      return directError;
    }
  }
}

ChannelConnectorError mapTunnelChannelError(
  FetchChannelTunnelUrlError? fetchError,
  ChannelCloseCode? closeCode,
) {
  if (fetchError == null && closeCode == null) {
    return ChannelConnectorError.unknownError;
  }

  if (fetchError != null) {
    switch (fetchError) {
      case FetchChannelTunnelUrlError.instanceNotFound:
        return ChannelConnectorError.instanceNotFound;

      case FetchChannelTunnelUrlError.unknownError:
        return ChannelConnectorError.unknownError;

      case FetchChannelTunnelUrlError.networkError:
      default:
        return ChannelConnectorError.networkError;
    }
  }

  return mapCloseCodeToChannelConnectorError(closeCode);
}

ChannelConnectorError mapCloseCodeToChannelConnectorError(
  ChannelCloseCode? closeCode,
) {
  switch (closeCode) {
    case ChannelCloseCode.instanceNotFound:
      return ChannelConnectorError.instanceNotFound;

    case ChannelCloseCode.authenticationError:
      return ChannelConnectorError.authenticationError;

    case ChannelCloseCode.invalidDisplayCode:
      return ChannelConnectorError.invalidDisplayCode;

    case ChannelCloseCode.networkError:
      return ChannelConnectorError.networkError;

    default:
      return ChannelConnectorError.unknownError;
  }
}
