import 'package:bonsoir/bonsoir.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'group_provider.dart';

final discoveryModelProvider = ChangeNotifierProvider<GroupListModel>((ref) {
  final groupNotifier = ref.read(groupProvider.notifier);
  GroupListModel model = GroupListModel(groupNotifier);
  return model;
});

class GroupListModel with ChangeNotifier {

  GroupListModel(this._groupProvider);

  String discoveryType = '_vs-airsync._tcp';
  BonsoirDiscovery? discovery;
  final GroupProvider _groupProvider;

  start() async {
    if (discovery?.isStopped == false) {
      return;
    }
    discovery = BonsoirDiscovery(type: discoveryType);

    await discovery?.ready;

    discovery?.eventStream!.listen(onEventOccurred);
    await discovery?.start();
  }

  stop() async {
    if (!(discovery?.isStopped ?? false)) {
      await discovery?.stop();
    }
  }

  void onEventOccurred(BonsoirDiscoveryEvent event) {
    if (event.service == null) {
      return;
    }
    BonsoirService service = event.service!;

    if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
      service.resolve(discovery!.serviceResolver);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
      GroupBean bean = GroupBean.fromJson(service.toJson());
      _groupProvider.addClient(bean);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
      GroupBean bean = GroupBean.fromJson(service.toJson());
      _groupProvider.removeClient(bean);
    }
    notifyListeners();
  }
}