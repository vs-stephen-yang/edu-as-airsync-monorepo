import 'package:bonsoir/bonsoir.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'channel_provider.dart';
import 'group_provider.dart';

final discoveryModelProvider = ChangeNotifierProvider<GroupListModel>((ref) {
  GroupListModel model = GroupListModel();
  return model;
});

class GroupListModel with ChangeNotifier {
  GroupListModel();

  static const String discoveryType = '_vs-airsync._tcp';
  static BonsoirDiscovery? discovery;
  static GroupProvider? _groupProvider;
  static bool _startDiscoveryService = false;
  static bool _stopDiscoveryService = false;
  final Map<String, DateTime> _serviceFoundTime = {};
  BuildContext? context;

  start({BuildContext? context}) async {
    this.context = context;
    if (discovery?.isStopped == false || _startDiscoveryService) {
      return;
    }
    _startDiscoveryService = true;
    try {
      discovery = BonsoirDiscovery(type: discoveryType);
      await discovery!.ready;
      discovery!.eventStream!.listen(onEventOccurred);
      await discovery!.start();
    } catch (e) {
      discovery = null;
      log.severe('Failed to start Bonjour Discovery', e);
    } finally {
      _startDiscoveryService = false;
    }
  }

  stop() async {
    if (discovery == null || _stopDiscoveryService) {
      return;
    }
    _stopDiscoveryService = true;
    try {
      if (!(discovery?.isStopped ?? false)) {
        await discovery?.stop();
      }
    } catch (e) {
      log.severe('Failed to stop Bonjour Discovery', e);
    } finally {
      discovery = null;
      _stopDiscoveryService = false;
    }
  }

  void onEventOccurred(BonsoirDiscoveryEvent event) {
    if (event.service == null) {
      return;
    }
    BonsoirService service = event.service!;

    if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
      bool containsName = _groupProvider
              ?.getClientList()
              .any((item) => item.serviceName() == service.name) ??
          false;
      if (discovery != null && !containsName) {
        service.resolve(discovery!.serviceResolver);
      }
    } else if (event.type ==
        BonsoirDiscoveryEventType.discoveryServiceResolved) {
      GroupBean bean = GroupBean.fromJson(service.toJson());
      if (bean.deviceName().isEmpty || bean.ip().isEmpty || bean.id().isEmpty) {
        return;
      }
      _groupProvider?.addClient(bean);
      _serviceFoundTime[bean.id()] = DateTime.now();
      log.info('group list add client:${bean.deviceName()}');
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
      GroupBean bean = GroupBean.fromJson(service.toJson());

      DateTime? addTime = _serviceFoundTime[bean.id()];
      // Service Found後，又馬上收到Service Lost，會被歸類為雜訊
      if (addTime != null && DateTime.now().difference(addTime).inMinutes < 5 ||
          bean.deviceName().isEmpty) {
        return;
      }
      // 若是host member正在播放中，bonsoir lost也不從清單刪除
      bool onGrouping = false;
      if (context != null && context!.mounted) {
        ChannelProvider channelProvider =
            provider.Provider.of<ChannelProvider>(context!, listen: false);
        if (channelProvider.groupActivated()) {
          onGrouping = channelProvider.isGroupHostMember(bean.id());
        }
      }
      if (!onGrouping) {
        _groupProvider?.removeClient(bean);
        log.info('group list remove Client:${bean.deviceName()}');
      }
    }
  }

  set groupProvider(GroupProvider value) {
    _groupProvider = value;
  }
}
