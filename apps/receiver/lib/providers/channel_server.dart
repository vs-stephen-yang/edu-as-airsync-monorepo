import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/settings/channel_config.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';

class ChannelServer {
  DisplayDirectServer? _directServer;
  DisplayTunnelServer? _tunnelServer;

  // Callback for handling new direct channel connections
  final Function(Channel channel, Map<String, String>? queryParameters)
      _onNewDirectChannel;

  // Callback for handling new tunnel channel connections
  final Function(Channel channel) _onNewTunnelChannel;

  // Callback for verifying connection requests
  final ConnectRequestStatus Function(
    ConnectionRequest connectionRequest, {
    required bool isDirectConnect,
  }) _verifyConnectRequest;

  ChannelServer(
    this._onNewDirectChannel,
    this._onNewTunnelChannel,
    this._verifyConnectRequest,
  );

  Future<void> startTunnel(
    String tunnelApiUrl,
    String instanceId,
    int instanceGroupId,
  ) async {
    stopTunnel();

    // Start the tunnel server
    log.info(
        'Starting the tunnel channel server $tunnelApiUrl $instanceGroupId');

    _setTunnelServer();
    _tunnelServer?.start(
      instanceId,
      instanceGroupId,
      Uri.parse(tunnelApiUrl),
    );
  }

  void stopTunnel() {
    if (_tunnelServer != null) {
      log.info('Stopping the tunnel channel server');
      _tunnelServer?.stop();
      _tunnelServer = null;
    }
  }

  Future<void> startDirect() async {
    stopDirect();

    // start the direct server
    try {
      final securityContext = await loadSecurityContextForChannel();

      log.info('Starting the direct channel server');

      _directServer = DisplayDirectServer(
        reconnectTimeout: channelReconnectTimeoutInStreaming,
        _onNewDirectChannel,
        (ConnectionRequest connectionRequest) =>
            _verifyConnectRequest(connectionRequest, isDirectConnect: true),
      );
      await _directServer?.start(
        DisplayServiceBroadcast.instance.directChannelPort,
        securityContext: securityContext,
      );
      log.info('Direct channel server has started');
    } on Exception catch (e) {
      log.severe('Failed to start direct channel server', e);
    }
  }

  void stopDirect() {
    if (_directServer != null) {
      log.info('Stopping direct channel server');
      _directServer?.stop();
      _directServer = null;
    }
  }

  void _setTunnelServer() {
    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
      reconnectTimeout: channelReconnectTimeoutInStreaming,
      (String url, bool isReconnect) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          logger: (url, message) {
            log.finest('Tunnel $message');
          },
        ),
      ),
      (Channel channel, _) => _onNewTunnelChannel(channel),
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest, isDirectConnect: false),
    );

    _tunnelServer?.onTunnelConnected = () {
      log.info('Tunnel connected');
      trackTrace('tunnel_connected');
    };
    _tunnelServer?.onTunnelConnecting = () {
      log.info('Tunnel is connecting');
      trackTrace('tunnel_connected');
    };
  }
}
