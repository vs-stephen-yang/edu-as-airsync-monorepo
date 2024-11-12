import 'dart:async';

import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/display_channel_client.dart';
import 'package:display_channel/src/display_code2.dart';

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
typedef FetchChannelTunnelUrl = Future<String> Function(
  int instanceIndex,
  int instanceGroupId,
);

enum ChannelConnectorError {
  instanceNotFound,
  authenticationError,
  authenticationRequired,
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
  final List<String>? _localIpAddresses;
  final String _otp;

  DisplayChannelClient? _tunnelClient;
  DisplayChannelClient? _directClient;

  StreamSubscription? _tunnelSubscription;
  StreamSubscription? _directSubscription;

  bool _connected = false;

  bool _useDirect = false;
  bool _useTunnel = false;

  bool _directFailed = false;
  bool _tunnelFailed = false;

  FetchChannelTunnelUrlError? _tunnelUrlFetchError;

  final void Function(Channel channel, bool isDirectChannel) _onOpened;
  final void Function(ChannelConnectorError error) _onOpenError;

  DisplayChannelConnector({
    required String clientId,
    required String otp,
    required DisplayCode displayCode,
    List<String>? localIpAddresses,
    required String encodedDisplayCode,
    required CreateWebsocketClientConnection createConnectionTunnel,
    required CreateWebsocketClientConnection createConnectionDirect,
    required FetchChannelTunnelUrl fetchTunnelUrl,
    required void Function(Channel channel, bool isDirectChannel) onOpened,
    required void Function(ChannelConnectorError error) onOpenError,
  })  : _clientId = clientId,
        _otp = otp,
        _displayCode = displayCode,
        _localIpAddresses = localIpAddresses,
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
    if (directPort != null && _localIpAddresses != null) {
      _useDirect = true;

      final remoteIpAddress = createRemoteIp(
        // TODO: handle multiple local IP addresses
        _localIpAddresses![0],
        _displayCode.instanceGroupId,
      );

      _openDirectChannel(
        remoteIpAddress,
        directPort,
      );
    }

    // open tunnel channel
    if (_displayCode.instanceIndex != null) {
      _useTunnel = true;

      // fetching the tunnel URL
      _fetchTunnelUrl(
        _displayCode.instanceIndex!,
        _displayCode.instanceGroupId,
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
      _displayCode.instanceIndex!,
      _displayCode.instanceGroupId,
      _otp,
      displayCode: _encodedDisplayCode,
    );

    _tunnelSubscription =
        _tunnelClient!.stateController.stream.listen((ChannelState state) {
      if (state == ChannelState.connected) {
        _onTunnelConnected();
      } else if (state == ChannelState.closed) {
        _tunnelFailed = true;
        _onConnectFailed();
      }
    });
  }

  // open direct channel
  _openDirectChannel(
    String ipAddress,
    int port,
  ) {
    final uri = Uri(
      scheme: 'wss',
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
      token: _otp,
      displayCode: _encodedDisplayCode,
    );

    _directSubscription =
        _directClient!.stateController.stream.listen((ChannelState state) {
      if (state == ChannelState.connected) {
        _onDirectConnected();
      } else if (state == ChannelState.closed) {
        _directFailed = true;
        _onConnectFailed();
      }
    });
  }

  // direct channel is connected
  _onDirectConnected() {
    if (_connected) {
      // Too late. The tunnel channel is already connected.
      // Close the direct channel
      _directClient?.close(null);
      _directSubscription?.cancel();
      _directClient?.stateController.close();
      return;
    }

    _connected = true;
    _onOpened(_directClient!, true);
  }

  // tunnel channel is connected
  _onTunnelConnected() {
    if (_connected) {
      // Too late. The direct channel is already connected.
      // Close the tunnel channel
      _tunnelClient?.close(null);
      _tunnelSubscription?.cancel();
      _tunnelClient?.stateController.close();
      return;
    }

    _connected = true;
    _onOpened(_tunnelClient!, false);
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

    case ChannelCloseCode.authenticationRequired:
      return ChannelConnectorError.authenticationRequired;

    default:
      return ChannelConnectorError.unknownError;
  }
}
