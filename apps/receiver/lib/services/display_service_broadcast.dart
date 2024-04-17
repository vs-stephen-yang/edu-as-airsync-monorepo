import 'package:bonsoir/bonsoir.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';

class DisplayServiceBroadcast {
  final String _serviceType;
  final int _port;
  final InstanceInfoProvider _instanceInfo;

  BonsoirBroadcast? _broadcast;

  DisplayServiceBroadcast(
    this._serviceType,
    this._port,
    this._instanceInfo,
  ) {
    _instanceInfo.addListener(_onInstanceInfoUpdated);

    if (_instanceInfo.deviceName.isNotEmpty) {
      _start();
    }
  }

  void _onInstanceInfoUpdated() {
    _restart();
  }

  Future<void> _start() async {
    assert(_instanceInfo.deviceName.isNotEmpty);

    final service = BonsoirService(
      name: _instanceInfo.deviceName,
      type: _serviceType,
      port: _port,
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
