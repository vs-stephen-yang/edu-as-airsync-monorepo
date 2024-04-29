import 'package:bonsoir/bonsoir.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:uuid/uuid.dart';

class DisplayServiceBroadcast {
  static late DisplayServiceBroadcast instance;

  final String _serviceType;
  final int _port;
  final InstanceInfoProvider _instanceInfo;
  final String version;

  BonsoirBroadcast? _broadcast;

  DisplayServiceBroadcast._internal(
    this._serviceType,
    this._port,
    this._instanceInfo,
    this.version,
  ) {
    _instanceInfo.addListener(_onInstanceInfoUpdated);

    if (_instanceInfo.deviceName.isNotEmpty) {
      _start();
    }
  }

  static void ensureInitialized(
    String serviceType,
    int port,
    InstanceInfoProvider instanceInfoProvider,
    String version,
  ) {
    instance = DisplayServiceBroadcast._internal(
      serviceType,
      port,
      instanceInfoProvider,
      version,
    );
  }

  void _onInstanceInfoUpdated() {
    _restart();
  }

  Future<void> _start() async {
    assert(_instanceInfo.deviceName.isNotEmpty);

    final service = BonsoirService(
      name: const Uuid().v4(),
      type: _serviceType,
      port: _port,
      attributes: {
        'fn': _instanceInfo.deviceName,
        'ver': version,
        'displayCode': _instanceInfo.displayCode,
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
