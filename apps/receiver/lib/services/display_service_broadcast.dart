import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:uuid/uuid.dart';

class DisplayServiceBroadcast {
  static DisplayServiceBroadcast? _singleton;

  static DisplayServiceBroadcast get instance => _singleton!;

  static void ensureInitialized({
    required String broadcastServiceType,
    required int directChannelPort,
    required String appVersion,
    required InstanceInfoProvider instanceInfoProvider,
    required String invitedToGroupOption,
  }) {
    if (_singleton != null) return;
    _singleton = DisplayServiceBroadcast._internal(
      broadcastServiceType,
      directChannelPort,
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

  BonsoirBroadcast? _broadcast;
  DateTime previousRestartTime = DateTime.fromMillisecondsSinceEpoch(0);

  // ---- 序列化所有 start/stop，避免併發 ----
  Future<void> _ops = Future.value();

  bool _isBroadcasting = false;
  bool _starting = false;
  bool _restartQueued = false;

  DisplayServiceBroadcast._internal(
    this._serviceType,
    this._directChannelPort,
    this._version,
    this._instanceInfo,
    this._invitedToGroupOption,
  ) {
    _instanceInfo.addListener(_onInstanceInfoUpdated);
    _queue(() async => _start());
  }

  void dispose() {
    _instanceInfo.removeListener(_onInstanceInfoUpdated);
    _queue(() async => _stop());
    _singleton = null;
  }

  Future<void> updateInvitedToGroupOption(String option) {
    if (_invitedToGroupOption == option) {
      // No change; avoid unnecessary restart
      return Future.value();
    }
    _invitedToGroupOption = option;
    // Force a restart so TXT attributes reflect the new value.
    return _restart(true);
  }

  void onBroadcastRestart() {
    _restart(true);
  }

  Future<T> _queue<T>(Future<T> Function() run) {
    _ops = _ops.then((_) => run(), onError: (_) => run());
    return _ops as Future<T>;
  }

  void _onInstanceInfoUpdated() {
    if (!_isInstanceInfoComplete()) {
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
    if (_starting || _isBroadcasting) return;
    if (!_isInstanceInfoComplete()) return;

    _starting = true;
    try {
      final service = BonsoirService(
        name: const Uuid().v4(),
        type: _serviceType,
        port: _directChannelPort,
        attributes: {
          'fn': _instanceInfo.deviceName,
          'ver': _version,
          'dc': _instanceInfo.displayCode,
          'ip': _instanceInfo.ipAddress,
          'igo': _invitedToGroupOption,
          'id': AppInstanceCreate().groupID,
          'mc': '1', // multicast
        },
      );

      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.ready;
      await _broadcast!.start();
      _isBroadcasting = true;
    } catch (e) {
      log.warning('Bonsoir start failed: $e');
      _broadcast = null;
      _isBroadcasting = false;
    } finally {
      _starting = false;
    }
  }

  Future<void> _stop() async {
    try {
      if (_broadcast != null) {
        await _broadcast!.stop();
      }
    } catch (e) {
      log.warning('Bonsoir stop failed: $e');
    } finally {
      _isBroadcasting = false;
      _broadcast = null;
    }
  }

  Future<void> _restart([bool force = false]) {
    final now = DateTime.now();
    // Throttle restarts within 5s unless explicitly forced
    if (!force && now.difference(previousRestartTime).inSeconds < 5) {
      _restartQueued = true;
      return Future.value();
    }
    previousRestartTime = now;

    return _queue(() async {
      await _stop();
      // Small buffer for Android NSD to fully release its listener
      await Future.delayed(const Duration(milliseconds: 500));
      if (_isInstanceInfoComplete()) {
        await _start();
      }
      if (_restartQueued) {
        _restartQueued = false;
        await _restart(true);
      }
    });
  }
}
