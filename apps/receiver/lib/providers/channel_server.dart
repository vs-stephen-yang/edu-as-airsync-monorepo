import 'dart:async';

import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/api/http_request.dart';
import 'package:display_flutter/api/instance_api.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/settings/channel_config.dart';
import 'package:display_flutter/utility/cancelable_task.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';

enum TunnelStatus {
  disabled('Disable'),
  checking('Checking'),
  unavailable('Unavailable'),
  connecting('Connecting'),
  connected('Connected');

  const TunnelStatus(this.value);

  final String value;
}

class ChannelServer {
  DisplayDirectServer? _directServer;
  WebTransportDirectServer? _webTransportDirectServer;
  DisplayTunnelServer? _tunnelServer;

  bool _tunnelEnabled = false;
  bool _directEnabled = false;

  final int webTransportServerPort;

  final int tunnelMaxRetry;
  final Duration tunnelRetryInterval;

  final String baseApiUrl;
  final String instanceId;

  bool get isTunnelAvailable =>
      _tunnelStatus == TunnelStatus.connected ||
      _tunnelStatus == TunnelStatus.connecting;

  TunnelStatus get tunnelStatus => _tunnelStatus;
  TunnelStatus _tunnelStatus = TunnelStatus.disabled;

  StreamController<bool> tunnelActivatedStream =
      StreamController<bool>.broadcast()..add(false);

  Timer? _tunnelActivatedDebounceTimer;

  // Provide a displayCode only if it is available (i.e., instanceGroupId is not zero).
  // If the instanceGroupId is 0, which means the code is not available,
  // the getter returns an empty string to indicate the absence of a valid code
  String get displayCode {
    if (_displayCode.instanceGroupId == 0) {
      return "";
    }
    return encodeDisplayCode(_displayCode);
  }

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

  final Function(int port, bool success, String? error) reportPortBindResult;
  final Function(bool success, String status) reportTunnelConnectResult;
  final Function(String date) reportWebTransportCertDate;

  ChannelServer({
    required this.onNewDirectChannel,
    required this.onNewTunnelChannel,
    required this.verifyConnectRequest,
    required this.onTunnelStatusChange,
    required this.onDisplayCodeChange,
    required this.baseApiUrl,
    required this.instanceId,
    required this.webTransportServerPort,
    required this.reportPortBindResult,
    required this.reportTunnelConnectResult,
    required this.reportWebTransportCertDate,
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
    // Start the direct server
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
      reportPortBindResult(
          DisplayServiceBroadcast.instance.directChannelPort, true, null);
      log.info('Direct channel server has started');
    } on Exception catch (e) {
      reportPortBindResult(DisplayServiceBroadcast.instance.directChannelPort,
          false, e.toString());
      log.severe('Failed to start direct channel server', e);
    }

    try {
      _webTransportDirectServer = WebTransportDirectServer(
        getWebTransportCert,
        reconnectTimeout: channelReconnectTimeoutInStreaming,
        onNewDirectChannel,
        (ConnectionRequest connectionRequest) =>
            verifyConnectRequest(connectionRequest, isDirectConnect: true),
      );

      WebTransportCertificate? webTransportCertificate =
          await getWebTransportCert();
      if (webTransportCertificate == null) {
        return;
      }
      reportWebTransportCertDate(webTransportCertificate.date);

      await _webTransportDirectServer?.start(webTransportServerPort,
          certPem: webTransportCertificate.certPem,
          keyPem: webTransportCertificate.keyPem);
      reportPortBindResult(webTransportServerPort, true, null);

      log.info('WebTransport channel server has started');
    } catch (e) {
      reportPortBindResult(webTransportServerPort, false, e.toString());
      log.warning('Failed to start webTransport server: $e');
    }
  }

  void _stopDirectServer() {
    if (_directServer != null) {
      log.info('Stopping direct channel server');
      _directServer?.stop();
      _directServer = null;
    }

    if (_webTransportDirectServer != null) {
      log.info('Stopping webTransport server');
      _webTransportDirectServer?.stop();
      _webTransportDirectServer = null;
    }
  }

  void _startTunnelServer(int instanceGroupId, String tunnelApiUrl) {
    _stopTunnel();

    // Create and start the tunnel server
    log.info('Creating the tunnel channel server');
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
      log.info('Tunnel channel connected');
      _changeTunnelStatus(TunnelStatus.connected);
      trackTrace('tunnel_connected');
    };

    _tunnelServer?.onTunnelConnecting = () {
      log.info('Tunnel channel connecting');
      _changeTunnelStatus(TunnelStatus.connecting);
      trackTrace('tunnel_connecting');
    };

    _tunnelServer?.reportTunnelConnectResult = reportTunnelConnectResult;

    _tunnelServer?.start(
      instanceId,
      instanceGroupId,
      Uri.parse(tunnelApiUrl),
    );
  }

  _trySetupTunnel(String ipAddress) {
    log.info('Setting up the tunnel with local IP address: $ipAddress');

    if (_tunnelSetupTask != null && !_tunnelSetupTask!.isCanceled) {
      log.info('Canceling the ongoing setup of the tunnel');
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
        log.info('Attempting to register instance with ID: $instanceId');
        final registerResult = await registerInstanceIndexById(
          baseApiUrl,
          instanceId,
          instanceGroupId,
        );
        if (task.isCanceled) {
          log.info('Tunnel setup task has been canceled');
          return; // The task has been canceled
        }

        // API call succeeds
        _handleRegisterResult(registerResult, instanceGroupId);
        return;
      } on HttpRequestException catch (e) {
        // API call fails
        log.warning('Failed to register instance. Attempt ${retry + 1}');
        _handleRegisterResult(null, instanceGroupId);

        if (!_shouldRetrySetupTunnel(e)) {
          log.warning('Abandoning further retry attempts');
          return; // Cannot recover from error. Should not retry.
        }
      }
      // Delay for the next retry
      await Future.delayed(tunnelRetryInterval);
      if (task.isCanceled) {
        log.info('Tunnel setup task has been canceled during delay');
        return; // The task has been canceled
      }
    }
    // Retry fails
    log.severe('All retry attempts for tunnel setup have failed');
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
    log.info('Successfully registered instance. Starting tunnel server');
    _updateDisplayCode(instanceGroupId, registerResult.instanceIndex);

    // Start the tunnel server.
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
      _debouncedTunnelActivatedUpdate(status);
      onTunnelStatusChange(_tunnelStatus);
    }
  }

  void _debouncedTunnelActivatedUpdate(TunnelStatus status) {
    _tunnelActivatedDebounceTimer?.cancel();

    _tunnelActivatedDebounceTimer =
        Timer(const Duration(milliseconds: 300), () {
      final activated =
          status == TunnelStatus.connected || status == TunnelStatus.connecting;
      tunnelActivatedStream.add(activated);
    });
  }

  void onIpAddressChange(String ipAddress) {
    if (_ipAddress == ipAddress) {
      log.info('IP address remains unchanged');
      // Notify the current display code
      onDisplayCodeChange();
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

    if (_tunnelEnabled == enable) {
      log.info('Tunnel channel remains unchanged');
      return;
    }
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

      if (_ipAddress != null) {
        final instanceGroupId = getInstanceGroupIdFromIp(_ipAddress!);
        _updateDisplayCode(instanceGroupId, null);
      }
    }
  }

  Future<void> enableDirect(bool enable) async {
    log.info('Enable direct channel: $enable');

    if (_directEnabled == enable) {
      log.info('direct channel remains unchanged');
      return;
    }

    _directEnabled = enable;

    if (enable) {
      _stopDirectServer();
      await _startDirectServer();

      if (_ipAddress != null) {
        // Notify the current display code
        onDisplayCodeChange();
      }
    } else {
      _stopDirectServer();
    }
  }

  // Return true if retry is possible
  bool _shouldRetrySetupTunnel(HttpRequestException e) {
    if (e.statusCode != null) {
      log.warning(
          'Abandoning retry attempts. API request failed with status code: ${e.statusCode}');
      return false;
    }
    return true;
  }
}
