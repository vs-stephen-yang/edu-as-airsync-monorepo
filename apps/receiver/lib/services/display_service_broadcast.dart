import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/network_constants.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:uuid/uuid.dart';

class DisplayServiceBroadcast {
  static DisplayServiceBroadcast? _singleton;

  static DisplayServiceBroadcast? get instance => _singleton;

  static const channelPort = 5100;
  static const serviceType = '_vs-airsync._tcp';

  static void ensureInitialized({
    required String appVersion,
    required InstanceInfoProvider instanceInfoProvider,
    required String invitedToGroupOption,
  }) {
    if (_singleton != null) return;
    _singleton = DisplayServiceBroadcast._internal(
      serviceType,
      channelPort,
      appVersion,
      instanceInfoProvider,
      invitedToGroupOption,
    );
  }

  final String _serviceType;
  final int _directChannelPort;
  final InstanceInfoProvider _instanceInfo;
  final String _version;
  String _invitedToGroupOption;

  int get directChannelPort => _directChannelPort;
  // Expose app version for UDP discovery responses.
  String get appVersion => _version;

  BonsoirBroadcast? _broadcast;

  // ---- 序列化所有 start/stop，避免併發 ----
  Future<void> _ops = Future.value();

  Timer? _restartTimer;
  static const Duration _restartDebounce = Duration(seconds: 5);

  //
  UdpResponder? udpResponder;

  DisplayServiceBroadcast._internal(
    this._serviceType,
    this._directChannelPort,
    this._version,
    this._instanceInfo,
    this._invitedToGroupOption,
  ) {
    _instanceInfo.addListener(_onInstanceInfoUpdated);
  }

  void dispose() {
    log.info('Broadcast dispose called');
    _instanceInfo.removeListener(_onInstanceInfoUpdated);
    _restartTimer?.cancel();
    _restartTimer = null;
    _queue(() async => _stop());
    _singleton = null;
  }

  Future<void> updateInvitedToGroupOption(String option) {
    if (_invitedToGroupOption == option) {
      // No change; avoid unnecessary restart
      return Future.value();
    }
    _invitedToGroupOption = option;
    // Use debounce to avoid burst restarts from rapid changes.
    return _restart();
  }

  void onBroadcastRestart() {
    _restart(true);
  }

  Future<T> _queue<T>(Future<T> Function() run) {
    _ops = _ops.then((_) => run(), onError: (_) => run());
    return _ops as Future<T>;
  }

  void _onInstanceInfoUpdated() {
    final isComplete = _isInstanceInfoComplete();
    log.info(
        'Broadcast instance info updated: complete=$isComplete deviceName=${_instanceInfo.deviceName} displayCode=${_instanceInfo.displayCode} ip=${_instanceInfo.ipAddress}');
    if (!isComplete) {
      _queue(() async => _stop());
      return;
    }
    _restart();
  }

  bool _isInstanceInfoComplete() {
    final i = _instanceInfo;
    return i.deviceName.isNotEmpty == true &&
        i.displayCode.isNotEmpty == true &&
        i.ipAddress.isNotEmpty == true;
  }

  Future<void> _start() async {
    if (!_isInstanceInfoComplete()) return;

    try {
      log.info(
          'Broadcast start begin: type=$_serviceType port=$_directChannelPort');
      final att = {
        'fn': _instanceInfo.deviceName,
        'ver': _version,
        'dc': _instanceInfo.displayCode,
        'ip': _instanceInfo.ipAddress,
        'igo': _invitedToGroupOption,
        'id': AppInstanceCreate().groupID,
        'mc': '1', // multicast
      };
      final service = BonsoirService(
        name: const Uuid().v4(),
        type: _serviceType,
        port: _directChannelPort,
        attributes: att,
      );

      // udp
      udpResponder ??= UdpResponder();
      final udpStarted = await udpResponder?.start(service.toJson());
      log.info('UDP responder start result: $udpStarted');

      _broadcast ??= BonsoirBroadcast(service: service);
      await _broadcast?.ready;
      await _broadcast?.start();
      log.info('Broadcast start completed');
    } catch (e) {
      log.warning('Bonsoir start failed: $e');
      try {
        await _broadcast?.stop();
      } catch (stopError) {
        log.warning('Bonsoir cleanup failed: $stopError');
      }
      _broadcast = null;
      udpResponder?.stop();
      udpResponder = null;
    }
  }

  Future<void> _stop() async {
    try {
      log.info('Broadcast stop begin');
      await _broadcast?.stop();
    } catch (e) {
      log.warning('Bonsoir stop failed: $e');
    } finally {
      udpResponder?.stop();
      _broadcast = null;
      udpResponder = null;
      log.info('Broadcast stop completed');
    }
  }

  Future<void> _restart([bool force = false]) {
    if (force) {
      if (_restartTimer != null) {
        _restartTimer?.cancel();
        _restartTimer = null;
        log.info('Broadcast restart debounce canceled (force)');
      }
      log.info('Broadcast restart forced');
      return _queue(() async => _performRestart());
    }

    final hadPending = _restartTimer != null;
    _restartTimer?.cancel();
    log.info('Broadcast restart debounce scheduling (delay=$_restartDebounce)');
    _restartTimer = Timer(_restartDebounce, () {
      _restartTimer = null;
      log.info('Broadcast restart debounce elapsed');
      _queue(() async => _performRestart());
    });
    log.info(hadPending
        ? 'Broadcast restart debounce reset'
        : 'Broadcast restart debounce scheduled');
    return Future.value();
  }

  Future<void> _performRestart() async {
    log.info(
        'Broadcast restart performing (complete=${_isInstanceInfoComplete()})');
    await _stop();
    // Small buffer for Android NSD to fully release its listener
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isInstanceInfoComplete()) {
      await _start();
    } else {
      log.info('Broadcast restart skipped: instance info incomplete');
    }
  }
}

class UdpResponder {
  static String udpMessage = NetworkConstants.airSyncMessage;
  static const int defaultPort = NetworkConstants.airSyncPort;
  static const int portRangeSize = NetworkConstants.airSyncPortRange;

  RawDatagramSocket? _sock;
  int? _activePort; // Track which port is actually being used

  int? get activePort => _activePort;

  Future<bool> start(Map<String, dynamic> att, {int port = defaultPort}) async {
    // Close existing socket before creating a new one to prevent resource leak
    stop();

    // Try binding to ports in the range [port, port + portRangeSize)
    bool bound = false;
    for (int tryPort = port; tryPort < port + portRangeSize; tryPort++) {
      try {
        _sock = await RawDatagramSocket.bind(InternetAddress.anyIPv4, tryPort);
        _activePort = tryPort;
        bound = true;

        _sock!.listen((event) {
          if (event == RawSocketEvent.read) {
            final dg = _sock!.receive();
            if (dg == null) return;
            final msg = utf8.decode(dg.data);
            if (msg == udpMessage) {
              final payload = jsonEncode(att);
              _sock!.send(utf8.encode(payload), dg.address, dg.port);
            }
          }
        });

        log.info('UDP responder started on port $tryPort');
        break; // Successfully bound, exit loop
      } catch (e) {
        // This port is occupied, try next one
        log.info('Port $tryPort is occupied, trying next port...');
        continue;
      }
    }

    if (!bound) {
      log.warning(
          'Failed to start UDP responder: all ports in range $port-${port + portRangeSize - 1} are occupied');
      _sock = null;
      _activePort = null;
    }
    return bound;
  }

  void stop() {
    _sock?.close();
    _sock = null;
    _activePort = null;
  }

  static Future<Map<String, dynamic>> askPeerViaUdp(String ip,
      {int startPort = defaultPort}) async {
    // Try ports in the range to find the active responder
    Exception? lastException;

    for (int tryPort = startPort;
        tryPort < startPort + portRangeSize;
        tryPort++) {
      try {
        final result = await _tryAskPeerOnPort(ip, tryPort);
        return result; // Success! Return immediately
      } catch (e) {
        lastException = e as Exception;
        // This port didn't respond, try next one
        continue;
      }
    }

    // All ports failed
    throw lastException ?? Exception('UDP query failed on all ports');
  }

  static Future<bool> checkConnection(String ip) async {
    try {
      final ping = Ping(ip, count: 1);
      // 監聽 stream 取得結果
      final data = await ping.stream.first;
      if (data.response != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> _tryAskPeerOnPort(
      String ip, int port) async {
    final sock = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    sock.send(utf8.encode(udpMessage), InternetAddress(ip), port);

    final c = Completer<Map<String, dynamic>>();
    late StreamSubscription sub;
    sub = sock.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = sock.receive();
        if (dg == null) return;
        final resp = jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>;
        c.complete(resp);
        sub.cancel();
        sock.close();
      }
    });

    return c.future.timeout(const Duration(milliseconds: 500), onTimeout: () {
      sub.cancel();
      sock.close();
      throw Exception('UDP timeout on port $port');
    });
  }
}
