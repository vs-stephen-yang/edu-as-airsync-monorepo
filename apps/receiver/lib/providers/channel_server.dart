import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/providers/instance_api.dart';
import 'package:display_flutter/settings/channel_config.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';

enum TunnelStatus {
  unavailable,
  connecting,
  connected,
}

class ChannelServer {
  DisplayDirectServer? _directServer;
  DisplayTunnelServer? _tunnelServer;

  final String baseApiUrl;
  final String instanceId;

  TunnelStatus get tunnelStatus => _tunnelStatus;
  TunnelStatus _tunnelStatus = TunnelStatus.unavailable;

  String? get displayCode => _displayCode;
  String? _displayCode;

  // Callback for handling new direct channel connections
  final Function(Channel channel, Map<String, String>? queryParameters)
      onNewDirectChannel;

  // Callback for handling new tunnel channel connections
  final Function(Channel channel) onNewTunnelChannel;

  // Callback for verifying connection requests
  final ConnectRequestStatus Function(
    ConnectionRequest connectionRequest, {
    required bool isDirectConnect,
  }) verifyConnectRequest;

  // Callback for tunnel status change
  final Function(TunnelStatus status) onTunnelStatusChange;

  // Callback for display code change
  final Function(String displayCode) onDisplayCodeChange;

  ChannelServer({
    required this.onNewDirectChannel,
    required this.onNewTunnelChannel,
    required this.verifyConnectRequest,
    required this.onTunnelStatusChange,
    required this.onDisplayCodeChange,
    required this.baseApiUrl,
    required this.instanceId,
  });

  Future<void> startTunnel(
    String ipAddress,
  ) async {
    await _setupTunnel(ipAddress);
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
        onNewDirectChannel,
        (ConnectionRequest connectionRequest) =>
            verifyConnectRequest(connectionRequest, isDirectConnect: true),
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
    stopTunnel();

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
      (Channel channel, _) => onNewTunnelChannel(channel),
      (ConnectionRequest connectionRequest) =>
          verifyConnectRequest(connectionRequest, isDirectConnect: false),
    );

    _tunnelServer?.onTunnelConnected = () {
      log.info('Tunnel connected');

      trackTrace('tunnel_connected');
    };

    _tunnelServer?.onTunnelConnecting = () {
      log.info('Tunnel connecting');

      trackTrace('tunnel_connecting');
    };
  }

  _setupTunnel(String ipAddress) async {
    log.info('Setting up the tunnel channel');

    // Get the instance group Id from IP address
    final instanceGroupId = getInstanceGroupIdFromIp(ipAddress);

    // Register
    final registerResult = await registerInstanceIndexById(
      baseApiUrl,
      instanceId,
      instanceGroupId,
    );

    if (registerResult == null) {
      // The API call fails.
      _updateDisplayCode(instanceGroupId, null);

      _changeTunnelStatus(TunnelStatus.unavailable);
      return;
    }

    // The API call succeeds.
    _updateDisplayCode(instanceGroupId, registerResult.instanceIndex);

    // Start the tunnel server.
    log.info('Starting the tunnel channel server');

    _setTunnelServer();
    _tunnelServer!.start(
      instanceId,
      instanceGroupId,
      Uri.parse(registerResult.tunnelApiUrl),
    );

    _changeTunnelStatus(TunnelStatus.connecting);
  }

  void _updateDisplayCode(int instanceGroupId, int? instanceIndex) {
    log.info(
        'Updating display code. instanceGroupId:$instanceGroupId instanceIndex:$instanceIndex');

    final displayCode = encodeDisplayCode(
      DisplayCode(
        instanceGroupId: instanceGroupId,
        instanceIndex: instanceIndex,
      ),
    );

    _displayCode = displayCode;
    onDisplayCodeChange(displayCode);
  }

  void _changeTunnelStatus(TunnelStatus status) {
    if (_tunnelStatus != status) {
      log.info('Tunnel status has changed to $status');
      _tunnelStatus = status;
      onTunnelStatusChange(_tunnelStatus);
    }
  }
}
