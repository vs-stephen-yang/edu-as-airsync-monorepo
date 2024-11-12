import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/api/http_request.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/api/instance_api.dart';
import 'package:display_flutter/settings/channel_config.dart';
import 'package:display_flutter/utility/cancelable_task.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';

enum TunnelStatus {
  disabled,
  checking,
  unavailable,
  connecting,
  connected,
}

class ChannelServer {
  DisplayDirectServer? _directServer;
  DisplayTunnelServer? _tunnelServer;

  bool _tunnelEnabled = false;

  final int tunnelMaxRetry;
  final Duration tunnelRetryInterval;

  final String baseApiUrl;
  final String instanceId;

  bool get isTunnelAvailable =>
      _tunnelStatus == TunnelStatus.connected ||
      _tunnelStatus == TunnelStatus.connecting;

  TunnelStatus get tunnelStatus => _tunnelStatus;
  TunnelStatus _tunnelStatus = TunnelStatus.disabled;

  String get displayCode => encodeDisplayCode(_displayCode);
  final _displayCode = DisplayCode(instanceGroupId: 0);

  CancelableTask? _tunnelSetupTask;

  String? _ipAddress;

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
  final Function() onDisplayCodeChange;

  ChannelServer({
    required this.onNewDirectChannel,
    required this.onNewTunnelChannel,
    required this.verifyConnectRequest,
    required this.onTunnelStatusChange,
    required this.onDisplayCodeChange,
    required this.baseApiUrl,
    required this.instanceId,
    this.tunnelMaxRetry = 30,
    this.tunnelRetryInterval = const Duration(minutes: 2),
  });

  void _stopTunnel() {
    if (_tunnelServer != null) {
      log.info('Stopping the tunnel channel server');
      _tunnelServer?.stop();
      _tunnelServer = null;
    }
  }

  Future<void> _startDirectServer() async {
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

  void _stopDirectServer() {
    if (_directServer != null) {
      log.info('Stopping direct channel server');
      _directServer?.stop();
      _directServer = null;
    }
  }

  void _startTunnelServer(int instanceGroupId, String tunnelApiUrl) {
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
      _changeTunnelStatus(TunnelStatus.connected);

      trackTrace('tunnel_connected');
    };

    _tunnelServer?.onTunnelConnecting = () {
      _changeTunnelStatus(TunnelStatus.connecting);

      trackTrace('tunnel_connecting');
    };

    _tunnelServer?.start(
      instanceId,
      instanceGroupId,
      Uri.parse(tunnelApiUrl),
    );
  }

  _trySetupTunnel(String ipAddress) {
    log.info('Setting up the tunnel with local IP address: $ipAddress');

    if (_tunnelSetupTask != null && !_tunnelSetupTask!.isCanceled) {
      log.info('Cancel the ongoing setup of the tunnel');
      _tunnelSetupTask?.cancel();
    }

    // Run a cancelable task
    _tunnelSetupTask = CancelableTask((task) async {
      await _runTunnelSetupTask(task, ipAddress);
    });

    _tunnelSetupTask?.run();
  }

  _runTunnelSetupTask(CancelableTask task, String ipAddress) async {
    // Get the instance group Id from IP address
    final instanceGroupId = getInstanceGroupIdFromIp(ipAddress);

    for (var retry = 0; retry < tunnelMaxRetry; retry += 1) {
      try {
        // Call API to register the tunnel
        final registerResult = await registerInstanceIndexById(
          baseApiUrl,
          instanceId,
          instanceGroupId,
        );
        if (task.isCanceled) {
          return; // The task has been canceled
        }

        // API call succeeds
        _handleRegisterResult(registerResult, instanceGroupId);
        return;
      } on HttpRequestException catch (e) {
        // API call fails
        _handleRegisterResult(null, instanceGroupId);

        if (!_shouldRetrySetupTunnel(e)) {
          return; // Cannot recover from error. Should not retry.
        }
      }
      // Delay for the next retry
      await Future.delayed(tunnelRetryInterval);
      if (task.isCanceled) {
        return; // The task has been canceled
      }
    }
    // Retry fails
    _handleRegisterResult(null, instanceGroupId);
  }

  void _handleRegisterResult(
    RegisterInstanceResult? registerResult,
    int instanceGroupId,
  ) {
    if (registerResult == null) {
      // The API call fails.
      log.info('The tunnel channel is unavailable');

      _updateDisplayCode(instanceGroupId, null);

      _changeTunnelStatus(TunnelStatus.unavailable);
      return;
    }

    // The API call succeeds.
    _updateDisplayCode(instanceGroupId, registerResult.instanceIndex);

    // Start the tunnel server.
    log.info('Starting the tunnel channel server');

    _startTunnelServer(instanceGroupId, registerResult.tunnelUrl);

    _changeTunnelStatus(TunnelStatus.connecting);
  }

  void _updateDisplayCode(int instanceGroupId, int? instanceIndex) {
    log.info(
        'Updating display code. instanceGroupId:$instanceGroupId instanceIndex:$instanceIndex');

    _displayCode.instanceGroupId = instanceGroupId;
    _displayCode.instanceIndex = instanceIndex;

    onDisplayCodeChange();
  }

  void _changeTunnelStatus(TunnelStatus status) {
    if (_tunnelStatus != status) {
      log.info('Tunnel status has changed to ${status.name}');
      _tunnelStatus = status;
      onTunnelStatusChange(_tunnelStatus);
    }
  }

  void onIpAddressChange(String ipAddress) {
    if (_ipAddress == ipAddress) {
      return;
    }

    log.info('Local IP address has changed to $ipAddress');

    _ipAddress = ipAddress;

    if (_tunnelEnabled) {
      _trySetupTunnel(ipAddress);
    } else {
      final instanceGroupId = getInstanceGroupIdFromIp(_ipAddress!);
      _updateDisplayCode(instanceGroupId, null);
    }
  }

  void enableTunnel(bool enable) {
    log.info('Enable tunnel channel: $enable');

    _tunnelEnabled = enable;

    if (enable) {
      _stopTunnel();
      _changeTunnelStatus(TunnelStatus.checking);

      if (_ipAddress != null) {
        _trySetupTunnel(_ipAddress!);
      }
    } else {
      _tunnelSetupTask?.cancel();
      _tunnelSetupTask = null;

      _stopTunnel();
      _changeTunnelStatus(TunnelStatus.disabled);
    }
  }

  Future<void> enableDirect(bool enable) async {
    log.info('Enable direct channel: $enable');

    if (enable) {
      _stopDirectServer();
      await _startDirectServer();

      if (_ipAddress != null) {
        final instanceGroupId = getInstanceGroupIdFromIp(_ipAddress!);
        _updateDisplayCode(instanceGroupId, null);
      }
    } else {
      _stopDirectServer();
    }
  }

  // Return true if the retry
  bool _shouldRetrySetupTunnel(HttpRequestException e) {
    if (e.statusCode != null) {
      log.warning(
          'Abandoning retry attempts. API request failed with status code: ${e.statusCode}');
      return false;
    }
    return true;
  }
}
