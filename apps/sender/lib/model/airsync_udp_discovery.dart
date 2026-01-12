import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/utilities/log.dart';

class AirSyncUdpDiscovery {
  AirSyncUdpDiscovery({
    required this.serviceType,
    required this.directChannelPort,
    required this.buildResponse,
    required this.onDevice,
    required this.onRemove,
  });

  static const Duration _interval = Duration(seconds: 2);
  static const Duration _burstDelay = Duration(milliseconds: 200);
  static const int _burstCount = 5;
  static const Duration _deviceTimeout = Duration(seconds: 5);
  static const Duration _broadcastCacheTtl = Duration(seconds: 30);

  // AirSync UDP discovery: broadcast "airsync" to 48469 to get JSON replies.
  static const String _airSyncMessage = 'airsync';
  static const int _airSyncPortStart = 48469;
  static const int _airSyncPortRange = 1;

  final String serviceType;
  final int directChannelPort;
  final String Function() buildResponse;
  final void Function(AirSyncBonsoirService) onDevice;
  final void Function(AirSyncBonsoirService) onRemove;

  final Map<String, RawDatagramSocket> _scanSockets = {};
  final Map<String, StreamSubscription<RawSocketEvent>> _scanSubs = {};
  Timer? _scanTimer;

  final Map<String, AirSyncBonsoirService> _devices = {};
  final Map<String, DateTime> _lastSeen = {};
  final Map<String, int> _scores = {};
  Map<String, List<InternetAddress>> _broadcastTargetsByIp = {};
  DateTime? _broadcastCacheTime;
  Set<String> _localIps = {};
  bool _logEnabled = false;

  void setLogEnabled(bool enabled) {
    _logEnabled = enabled;
  }

  Future<void> _syncScanSockets(
    Map<String, InternetAddress> addrByIp,
  ) async {
    final desiredIps = addrByIp.keys.toSet();
    final currentIps = _scanSockets.keys.toSet();

    for (final ip in currentIps.difference(desiredIps)) {
      _scanSubs.remove(ip)?.cancel();
      _scanSockets.remove(ip)?.close();
    }

    for (final ip in desiredIps.difference(currentIps)) {
      final addr = addrByIp[ip];
      if (addr == null) continue;
      try {
        final socket = await RawDatagramSocket.bind(addr, 0);
        socket.broadcastEnabled = true;
        _scanSockets[ip] = socket;
        _scanSubs[ip] = socket.listen((event) {
          if (event == RawSocketEvent.read) {
            final dg = socket.receive();
            if (dg == null) return;
            _handleAirSyncResponse(dg);
          }
        });
      } on SocketException catch (e) {
        if (_logEnabled) {
          log.fine('airsync udp bind failed: ${addr.address}: $e');
        }
      }
    }
  }

  Future<void> scanOnce() async {
    if (_scanSockets.isEmpty) {
      await start();
      return;
    }
    await _refreshBroadcastTargets();
    _sendAirSyncPacket();
    _pruneDevices();
  }

  Future<void> start() async {
    if (_scanSockets.isNotEmpty) return;
    try {
      // Resolve broadcast targets (subnet broadcast, 255.255.255.255, multicast).
      await _refreshBroadcastTargets();
      if (_scanSockets.isEmpty) {
        log.warning(
            'AirSync UDP discovery start failed: no usable IPv4 address');
        return;
      }
      await _sendAirSyncBurst();
      _pruneDevices();
      _scanTimer?.cancel();
      _scanTimer = Timer.periodic(_interval, (_) async {
        await _refreshBroadcastTargets();
        _sendAirSyncPacket();
        _pruneDevices();
      });
    } catch (e) {
      log.warning('AirSync UDP discovery start failed', e);
      stop();
    }
  }

  void stop() {
    _scanTimer?.cancel();
    _scanTimer = null;
    for (final sub in _scanSubs.values) {
      sub.cancel();
    }
    _scanSubs.clear();
    for (final socket in _scanSockets.values) {
      socket.close();
    }
    _scanSockets.clear();

    _devices.clear();
    _lastSeen.clear();
    _scores.clear();
    _broadcastTargetsByIp = {};
    _broadcastCacheTime = null;
    _localIps = {};
  }

  void _sendAirSyncPacket() {
    final payload = utf8.encode(_airSyncMessage);
    _scanSockets.forEach((ip, socket) {
      final targets = _broadcastTargetsByIp[ip];
      if (targets == null) return;
      for (final target in targets) {
        for (int i = 0; i < _airSyncPortRange; i++) {
          try {
            if (_logEnabled) {
              log.info(
                  'airsync udp send: local=$ip target=${target.address}:${_airSyncPortStart + i}');
            }
            socket.send(payload, target, _airSyncPortStart + i);
          } catch (e) {
            // Ignore per-target send failures (e.g. no route on Windows).
            if (_logEnabled) {
              log.fine(
                  'airsync udp send failed: local=$ip target=${target.address}:${_airSyncPortStart + i}');
            }
          }
        }
      }
    });
  }

  Future<void> _sendAirSyncBurst() async {
    for (int i = 0; i < _burstCount; i++) {
      _sendAirSyncPacket();
      if (i < _burstCount - 1) {
        await Future.delayed(_burstDelay);
      }
    }
  }

  void _handleAirSyncResponse(Datagram dg) {
    Map<String, dynamic> data;
    String raw = '';
    try {
      raw = utf8.decode(dg.data);
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e, st) {
      log.warning(
        'UDP discovery failed to decode response from ${dg.address.address}',
        e,
        st,
      );
      return;
    }

    // Accept both direct JSON and bonjour-style {"service.attributes": {...}}.
    Map<String, dynamic> attrMap = data;
    if (data['service.attributes'] is Map) {
      attrMap = Map<String, dynamic>.from(data['service.attributes'] as Map);
    }

    final ip = (attrMap['ip'] ?? dg.address.address).toString();
    if (ip.isEmpty || _localIps.contains(ip)) return;

    String name = (attrMap['fn'] ?? '').toString();
    final id = (attrMap['id'] ?? 'udp-airsync-$ip').toString();
    final ver = (attrMap['ver'] ?? '').toString();
    final dc = (attrMap['dc'] ?? '').toString();
    final igo = (attrMap['igo'] ?? '0').toString();
    final mc = (attrMap['mc'] ?? '').toString();
    if (name.isEmpty) {
      name = ip.isNotEmpty ? ip : id;
    }
    // No display code means the peer hasn't registered yet; skip listing.
    if (dc.isEmpty) {
      return;
    }

    final bean = AirSyncBonsoirService(
      uuid: id,
      name: name,
      type: serviceType,
      displayCode: dc,
      ip: ip,
      port: directChannelPort,
      source: DeviceSource.udp,
    );

    _lastSeen[id] = DateTime.now();
    _scores[id] = 10;

    if (_logEnabled) {
      log.info('airsync device refresh: $id ip=$ip name=$name ver=$ver');
      if (name == ip || name == id) {
        log.info('airsync device missing fn: $raw');
      }
      if (dc.isEmpty) {
        log.info('airsync device missing dc: $raw');
      }
      if (igo.isNotEmpty || mc.isNotEmpty) {
        log.fine('airsync device extra: igo=$igo mc=$mc');
      }
    }

    final previous = _devices[id];
    _devices[id] = bean;
    if (previous == null ||
        previous.ip != bean.ip ||
        previous.displayCode != bean.displayCode ||
        previous.name != bean.name) {
      onDevice(bean);
    } else if (_logEnabled) {
      log.fine('airsync device unchanged: $id ip=$ip');
    }
  }

  Future<void> _refreshBroadcastTargets() async {
    final now = DateTime.now();
    if (_broadcastCacheTime != null &&
        now.difference(_broadcastCacheTime!) < _broadcastCacheTtl) {
      return;
    }

    final targetsByIp = <String, List<InternetAddress>>{};
    final localIps = <String>{};
    final addrByIp = <String, InternetAddress>{};

    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          localIps.add(ip);
          addrByIp[ip] = addr;
          final bytes = Uint8List.fromList(addr.rawAddress);
          if (bytes.length == 4) {
            bytes[3] = 255;
            final subnetBroadcast = InternetAddress.fromRawAddress(bytes);
            targetsByIp[ip] = <InternetAddress>[
              subnetBroadcast,
              InternetAddress('255.255.255.255'),
              InternetAddress('239.255.255.250'),
            ];
          }
        }
      }
    } catch (e) {
      log.warning('Failed to list network interfaces', e);
    }

    await _syncScanSockets(addrByIp);

    _broadcastTargetsByIp = targetsByIp;
    _broadcastCacheTime = now;
    _localIps = localIps;
  }

  void _pruneDevices() {
    final now = DateTime.now();
    final toRemove = <String>[];
    _lastSeen.forEach((id, last) {
      if (now.difference(last) > _deviceTimeout) {
        final score = (_scores[id] ?? 10) - 1;
        if (score <= 0) {
          toRemove.add(id);
        } else {
          _scores[id] = score;
          _lastSeen[id] = now;
          if (_logEnabled) {
            log.info('airsync device score decay: $id score=$score');
          }
        }
      }
    });

    for (final id in toRemove) {
      final bean = _devices.remove(id);
      _lastSeen.remove(id);
      _scores.remove(id);
      if (bean != null) {
        if (_logEnabled) {
          log.info('airsync device remove: $id score=0');
        }
        onRemove(bean);
      }
    }
  }
}
