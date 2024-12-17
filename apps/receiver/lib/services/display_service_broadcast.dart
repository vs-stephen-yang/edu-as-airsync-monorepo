import 'dart:convert';

import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:nsd/nsd.dart';
import 'package:uuid/uuid.dart';

class DisplayServiceBroadcast {
  static late DisplayServiceBroadcast instance;

  final String _serviceType;
  final int _directChannelPort;
  final InstanceInfoProvider _instanceInfo;
  final String _version;
  static const utf8encoder = Utf8Encoder();
  String _invitedToGroupOption;

  int get directChannelPort => _directChannelPort;

  Registration? _broadcast;
  DateTime previousRestartTime = DateTime(0);

  DisplayServiceBroadcast._internal(
    this._serviceType,
    this._directChannelPort,
    this._version,
    this._instanceInfo,
    this._invitedToGroupOption,
  ) {
    _instanceInfo.addListener(_onInstanceInfoUpdated);

    _start();
  }

  static void ensureInitialized({
    required String broadcastServiceType,
    required int directChannelPort,
    required String appVersion,
    required InstanceInfoProvider instanceInfoProvider,
    required String invitedToGroupOption,
  }) {
    instance = DisplayServiceBroadcast._internal(
      broadcastServiceType,
      directChannelPort,
      appVersion,
      instanceInfoProvider,
      invitedToGroupOption,
    );
  }

  updateInvitedToGroupOption(String option) async {
    _invitedToGroupOption = option;
    await _restart(changeGroupOption: true);
  }

  void _onInstanceInfoUpdated() {
    _restart();
  }

  void onBroadcastRestart() {
    _restart();
  }

  bool isInstanceInfoComplete(InstanceInfoProvider instanceInfo) {
    return instanceInfo.deviceName.isNotEmpty &&
        instanceInfo.displayCode.isNotEmpty &&
        instanceInfo.ipAddress.isNotEmpty;
  }

  Future<void> _start() async {
    // start only if the information is complete
    if (!isInstanceInfoComplete(_instanceInfo)) {
      return;
    }

    final service = Service(
      name: const Uuid().v4(), // 經實驗重啟broadcast，name需要更換，否則discovery狀態無法更新。
      type: _serviceType,
      port: _directChannelPort,
      txt: {
        'fn': utf8encoder.convert(_instanceInfo.deviceName),
        'ver': utf8encoder.convert(_version),
        'dc': utf8encoder.convert(_instanceInfo.displayCode),
        'ip': utf8encoder.convert(_instanceInfo.ipAddress),
        'igo': utf8encoder.convert(_invitedToGroupOption),
        'id': utf8encoder.convert(AppInstanceCreate().groupID),
      },
    );

    _broadcast = await register(service);
  }

  Future<void> _stop() async {
    if (_broadcast != null) {
      await unregister(_broadcast!);
      _broadcast = null;
    }
  }

  Future<void> _restart({bool changeGroupOption = false}) async {
    final now = DateTime.now();
    // 避免頻繁重啟
    if (now.difference(previousRestartTime).inSeconds > 5 ||
        changeGroupOption) {
      previousRestartTime = now;
      await _stop();
      await _start();
    }
  }
}
