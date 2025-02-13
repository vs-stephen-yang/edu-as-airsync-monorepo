import 'dart:async';

import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/display_channel_client.dart';
import 'package:display_channel/src/display_code2.dart';

enum FetchChannelTunnelUrlError {
  instanceNotFound,
  instanceOffline,
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
  instanceOffline,
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
  final List<String>? _remoteIpAddresses;
  final String _otp;

  DisplayChannelClient? _tunnelClient;
  final _directClients = <String, DisplayChannelClient>{};

  StreamSubscription? _tunnelSubscription;
  final _directSubscriptions = <String, StreamSubscription<ChannelState>>{};

  bool _connected = false;

  bool _useDirect = false;
  bool _useTunnel = false;

  bool _tunnelFailed = false;
  final Set<String> _failedDirectIps = <String>{};

  FetchChannelTunnelUrlError? _tunnelUrlFetchError;

  final void Function(Channel channel, bool isDirectChannel) _onOpened;
  final void Function(ChannelConnectorError error) _onOpenError;

  DisplayChannelConnector({
    required String clientId,
    required String otp,
    required DisplayCode displayCode,
    List<String>? remoteIpAddresses,
    required String encodedDisplayCode,
    required CreateWebsocketClientConnection createConnectionTunnel,
    required CreateWebsocketClientConnection createConnectionDirect,
    required FetchChannelTunnelUrl fetchTunnelUrl,
    required void Function(Channel channel, bool isDirectChannel) onOpened,
    required void Function(ChannelConnectorError error) onOpenError,
  })  : _clientId = clientId,
        _otp = otp,
        _displayCode = displayCode,
        _remoteIpAddresses = remoteIpAddresses,
        _encodedDisplayCode = encodedDisplayCode,
        _createConnectionTunnel = createConnectionTunnel,
        _createConnectionDirect = createConnectionDirect,
        _fetchTunnelUrl = fetchTunnelUrl,
        _onOpened = onOpened,
        _onOpenError = onOpenError;

  void open({
    int? directPort,
  }) {
    // open direct channels
    if (directPort != null && _remoteIpAddresses?.isNotEmpty == true) {
      _useDirect = true;

      for (final remoteIp in _remoteIpAddresses!) {
        _openDirectChannel(
          remoteIp,
          directPort,
        );
      }
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
        _tunnelClient!.stateStream.listen((ChannelState state) {
      if (state == ChannelState.connected) {
        _onTunnelConnected();
      } else if (state == ChannelState.closed) {
        _tunnelFailed = true;
        _onConnectFailed();
      }
    });
  }

  void _openDirectChannel(
    String ipAddress,
    int port,
  ) {
    final uri = Uri(
      scheme: 'wss',
      host: ipAddress,
      port: port,
    );

    // create a channel client
    final directClient = DisplayChannelClient(
      _clientId,
      uri,
      _createConnectionDirect,
    );
    _directClients[ipAddress] = directClient;

    // open the client
    directClient.openDirectChannel(
      token: _otp,
      displayCode: _encodedDisplayCode,
    );

    _directSubscriptions[ipAddress] =
        directClient.stateStream.listen((ChannelState state) {
      if (state == ChannelState.connected) {
        _onDirectConnected(ipAddress);
      } else if (state == ChannelState.closed) {
        _failedDirectIps.add(ipAddress);
        _onDirectFailed(ipAddress);
      }
    });
  }

  void _onDirectFailed(String ipAddress) {
    _onConnectFailed();
  }

  // One of channels is connected
  _handleChannelOpened(Channel channel, bool isDirectChannel) {
    _tunnelSubscription?.cancel();

    // Cancel all direct subscriptions
    for (final subscription in _directSubscriptions.values) {
      subscription.cancel();
    }
    _directSubscriptions.clear();

    _connected = true;
    _onOpened(channel, isDirectChannel);
  }

  // Close all direct connections except the successful one
  void _closeOtherDirectConnections(String successfulIp) {
    for (final entry in _directClients.entries) {
      if (entry.key != successfulIp) {
        entry.value.close(null);
        _directSubscriptions[entry.key]?.cancel();
      }
    }
  }

  // direct channel is connected
  void _onDirectConnected(String ipAddress) {
    if (_connected) {
      // Too late. Another channel is already connected.
      // Close this direct channel
      _directClients[ipAddress]?.close(null);
      return;
    }

    _closeOtherDirectConnections(ipAddress);
    _handleChannelOpened(_directClients[ipAddress]!, true);
  }

  // tunnel channel is connected
  _onTunnelConnected() {
    if (_connected) {
      // Too late. The direct channel is already connected.
      // Close the tunnel channel
      _tunnelClient?.close(null);
      return;
    }

    _handleChannelOpened(_tunnelClient!, false);
  }

  _mapDualConnectError() {
    //tunnel error
    final tunnelError = mapTunnelChannelError(
      _tunnelUrlFetchError,
      _tunnelClient?.closeReason?.code,
    );

    //direct error - use first failed client's error code
    ChannelConnectorError directError = ChannelConnectorError.unknownError;
    if (_failedDirectIps.isNotEmpty) {
      // Get error from any of the failed clients
      for (final client in _directClients.values) {
        if (client.closeReason != null) {
          directError =
              mapCloseCodeToChannelConnectorError(client.closeReason?.code);
          break;
        }
      }
    }

    return mapDualConnectError(
      directError,
      tunnelError,
    );
  }

  _onConnectFailed() {
    if (_useDirect && _useTunnel) {
      // dual connections: direct and tunnel
      if (_failedDirectIps.length == _remoteIpAddresses!.length &&
          _tunnelFailed) {
        // Only report error if ALL direct connections have failed AND tunnel has failed
        final error = _mapDualConnectError();
        _onOpenError(error);
      }
    } else {
      // single connection: direct or tunnel
      if (_useTunnel) {
        assert(_tunnelFailed);
        // For tunnel-only, report error immediately since there's only one connection
        final error = mapTunnelChannelError(
          _tunnelUrlFetchError,
          _tunnelClient?.closeReason?.code,
        );
        _onOpenError(error);
      } else if (_failedDirectIps.length == _remoteIpAddresses!.length) {
        // For direct-only, only report error if ALL direct connections have failed
        ChannelConnectorError error = ChannelConnectorError.unknownError;
        for (final client in _directClients.values) {
          if (client.closeReason != null) {
            error =
                mapCloseCodeToChannelConnectorError(client.closeReason?.code);
            break;
          }
        }
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

      case FetchChannelTunnelUrlError.instanceOffline:
        return ChannelConnectorError.instanceOffline;

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
