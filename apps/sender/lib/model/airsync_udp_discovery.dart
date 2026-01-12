import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  RawDatagramSocket? _scanSocket;
  StreamSubscription<RawSocketEvent>? _scanSub;
  Timer? _scanTimer;

  final Map<String, AirSyncBonsoirService> _devices = {};
  final Map<String, DateTime> _lastSeen = {};
  final Map<String, int> _scores = {};
  List<InternetAddress> _broadcastTargets = [];
  DateTime? _broadcastCacheTime;
  Set<String> _localIps = {};
  bool _logEnabled = false;

  void setLogEnabled(bool enabled) {
    _logEnabled = enabled;
  }

  Future<void> scanOnce() async {
    if (_scanSocket == null) {
      await start();
      return;
    }
    await _refreshBroadcastTargets();
    _sendAirSyncPacket();
    _pruneDevices();
  }

  Future<void> start() async {
    if (_scanSocket != null) return;
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      _scanSocket = socket;

      _scanSub = socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = socket.receive();
          if (dg == null) return;
          _handleAirSyncResponse(dg);
        }
      });

      // Resolve broadcast targets (subnet broadcast, 255.255.255.255, multicast).
      await _refreshBroadcastTargets();
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
    _scanSub?.cancel();
    _scanSub = null;
    _scanSocket?.close();
    _scanSocket = null;

    _devices.clear();
    _lastSeen.clear();
    _scores.clear();
    _broadcastTargets = [];
    _broadcastCacheTime = null;
    _localIps = {};
  }

  void _sendAirSyncPacket() {
    final socket = _scanSocket;
    if (socket == null) return;
    final payload = utf8.encode(_airSyncMessage);
    for (final target in _broadcastTargets) {
      for (int i = 0; i < _airSyncPortRange; i++) {
        socket.send(payload, target, _airSyncPortStart + i);
      }
    }
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
      source: 'udp',
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

    final targets = <InternetAddress>{};
    final localIps = <String>{};

    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          localIps.add(ip);
          final bytes = addr.rawAddress;
          if (bytes.length == 4) {
            bytes[3] = 255;
            targets.add(InternetAddress.fromRawAddress(bytes));
          }
        }
      }
    } catch (e) {
      log.warning('Failed to list network interfaces', e);
    }

    // Global broadcast (vCast compatible) and SSDP multicast fallback.
    targets.add(InternetAddress('255.255.255.255'));
    targets.add(InternetAddress('239.255.255.250'));

    _broadcastTargets = targets.toList();
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
