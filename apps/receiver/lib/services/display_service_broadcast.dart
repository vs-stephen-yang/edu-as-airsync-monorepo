import 'package:bonsoir/bonsoir.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:uuid/uuid.dart';

class DisplayServiceBroadcast {
  static late DisplayServiceBroadcast instance;

  final String _serviceType;
  final int _port;
  final InstanceInfoProvider _instanceInfo;
  final String version;
  final String uuid = const Uuid().v4();

  BonsoirBroadcast? _broadcast;

  DisplayServiceBroadcast._internal(
    this._serviceType,
    this._port,
    this.version,
    this._instanceInfo,
  ) {
    _instanceInfo.addListener(_onInstanceInfoUpdated);

    _start();
  }

  static void ensureInitialized(
    AppConfig appConfig,
    InstanceInfoProvider instanceInfoProvider,
  ) {
    instance = DisplayServiceBroadcast._internal(
      appConfig.broadcastServiceType,
      appConfig.directChannelPort,
      appConfig.appVersion,
      instanceInfoProvider,
    );
  }

  void _onInstanceInfoUpdated() {
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

    final service = BonsoirService(
      name: uuid,
      type: _serviceType,
      port: _port,
      attributes: {
        'fn': _instanceInfo.deviceName,
        'ver': version,
        'dc': _instanceInfo.displayCode,
        'ip': _instanceInfo.ipAddress,
      },
    );

    _broadcast = BonsoirBroadcast(service: service);

    await _broadcast!.ready;
    await _broadcast!.start();
  }

  Future<void> _stop() async {
    await _broadcast?.stop();
    _broadcast = null;
  }

  Future<void> _restart() async {
    await _stop();
    await _start();
  }
}
