import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'channel_provider.dart';
import 'group_provider.dart';

final discoveryModelProvider = ChangeNotifierProvider<GroupListModel>((ref) {
  return GroupListModel();
});

class GroupListModel with ChangeNotifier {
  GroupListModel();

  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;
  GroupProvider? _groupProvider;

  final Map<String, DateTime> _serviceFoundTime = {};
  final Map<String, DateTime> _resolveRecent = {};
  final Set<String> _resolvePending = {};
  final List<BonsoirService> _resolveQueue = [];
  bool _resolving = false;

  static const Duration _resolveTimeout = Duration(seconds: 5);
  static const Duration _resolveCooldown = Duration(seconds: 3);

  // ---- 序列化所有 start/stop，避免併發 ----
  Future<void> _ops = Future.value();

  Future<T> _queue<T>(Future<T> Function() run) {
    _ops = _ops.then((_) => run(), onError: (_) => run());
    return _ops as Future<T>;
  }

  Future<void> start({required BuildContext context}) => _queue(() async {
        // 若已在探索中就不重入
        if (_discovery != null && !(_discovery!.isStopped)) return;

        // 先確保沒有殘留 listener
        await _safeStop();

        final discovery =
            BonsoirDiscovery(type: DisplayServiceBroadcast.serviceType);
        await discovery.ready;

        // 使用「這次的 discovery」當作 resolver 來源，避免 race
        _discoverySub =
            discovery.eventStream!.listen((BonsoirDiscoveryEvent event) async {
          final BonsoirService? service = event.service;
          if (service == null) return;

          switch (event.type) {
            case BonsoirDiscoveryEventType.discoveryServiceFound:
              final alreadyInList = _groupProvider
                      ?.getClientList()
                      .any((item) => item.serviceName() == service.name) ??
                  false;
              if (!alreadyInList) {
                _enqueueResolve(service, discovery);
              }
              break;

            case BonsoirDiscoveryEventType.discoveryServiceResolved:
              final bean = GroupBean.fromJson(service.toJson());
              if (bean.deviceName().isEmpty ||
                  bean.ip().isEmpty ||
                  bean.id().isEmpty) {
                return;
              }
              _groupProvider?.addClient(bean);
              _serviceFoundTime[bean.id()] = DateTime.now();
              log.info('group list add client: ${bean.deviceName()}');
              break;

            case BonsoirDiscoveryEventType.discoveryServiceLost:
              final attrs = service.attributes;
              if (!attrs.containsValue('AirSync')) return;

              final bean = GroupBean.fromJson(service.toJson());
              final addTime = _serviceFoundTime[bean.id()];

              // Found 後立刻 Lost 視為雜訊（<5 分鐘）或名稱無效時忽略
              if ((addTime != null &&
                      DateTime.now().difference(addTime).inMinutes < 5) ||
                  bean.deviceName().isEmpty) {
                return;
              }

              bool onGrouping = false;
              if (context.mounted) {
                final channelProvider = provider.Provider.of<ChannelProvider>(
                    context,
                    listen: false);
                if (channelProvider.groupActivated()) {
                  onGrouping = channelProvider.isGroupHostMember(bean.id());
                }
              }
              if (!onGrouping) {
                _groupProvider?.removeClient(bean);
                log.info('group list remove client: ${bean.deviceName()}');
              }
              break;

            default:
              break;
          }
        });

        try {
          await discovery.start();
          _discovery = discovery;
        } on PlatformException catch (e) {
          final msg = (e.message ?? '').toLowerCase();
          if (msg.contains('listener already in use')) {
            await _safeStop();
            await Future.delayed(const Duration(milliseconds: 150));
            await discovery.start();
            _discovery = discovery;
          } else {
            await _safeStop();
            log.severe('Failed to start Bonjour Discovery', e);
            rethrow;
          }
        } catch (e) {
          await _safeStop();
          log.severe('Failed to start Bonjour Discovery', e);
          rethrow;
        }
      });

  Future<void> stop() => _queue(_safeStop);

  void _enqueueResolve(BonsoirService service, BonsoirDiscovery discovery) {
    final last = _resolveRecent[service.name];
    if (last != null &&
        DateTime.now().difference(last) < _resolveCooldown) {
      return;
    }
    if (_resolvePending.contains(service.name)) return;
    _resolvePending.add(service.name);
    _resolveRecent[service.name] = DateTime.now();
    _resolveQueue.add(service);
    _drainResolveQueue(discovery);
  }

  void _drainResolveQueue(BonsoirDiscovery discovery) {
    if (_resolving) return;
    _resolving = true;

    () async {
      while (_resolveQueue.isNotEmpty) {
        if (_discovery != discovery) break;

        final service = _resolveQueue.removeAt(0);
        try {
          await service
              .resolve(discovery.serviceResolver)
              .timeout(_resolveTimeout);
        } catch (e) {
          log.warning('Resolve service failed: ${service.name}', e);
        } finally {
          _resolvePending.remove(service.name);
        }
      }
      _resolving = false;
    }();
  }

  Future<void> _safeStop() async {
    // 先停用訂閱（避免新事件在 stop 途中進來）
    final sub = _discoverySub;
    _discoverySub = null;
    await sub?.cancel();

    final d = _discovery;
    _discovery = null;
    _resolveQueue.clear();
    _resolvePending.clear();
    _resolveRecent.clear();
    _resolving = false;

    if (d != null) {
      try {
        if (!(d.isStopped)) {
          await d.stop();
        }
      } catch (e) {
        log.warning('Failed to stop Bonjour Discovery', e);
      }
    }
  }

  set groupProvider(GroupProvider value) {
    _groupProvider = value;
  }
}
