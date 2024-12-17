import 'dart:convert';

import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'package:provider/provider.dart' as provider;

import 'channel_provider.dart';
import 'group_provider.dart';

final discoveryModelProvider = ChangeNotifierProvider<GroupListModel>((ref) {
  final groupNotifier = ref.read(groupProvider.notifier);
  GroupListModel model = GroupListModel(groupNotifier);
  return model;
});

class GroupListModel with ChangeNotifier {
  GroupListModel(this._groupProvider);

  static const String discoveryType = '_vs-airsync._tcp';
  static Discovery? discovery;
  final GroupProvider _groupProvider;
  BuildContext? context;

  start({BuildContext? context}) async {
    this.context = context;
    if (discovery != null) {
      return;
    }
    discovery = await startDiscovery(discoveryType);
    discovery!.addServiceListener(onEventOccurred);
  }

  stop() async {
    if (discovery != null) {
      try {
        await stopDiscovery(discovery!);
        discovery?.removeServiceListener(onEventOccurred);
        discovery?.dispose();
      } catch (e) {
        log.severe('Failed to stop Bonjour Discovery', e);
      } finally {
        discovery = null;
      }
    }
  }

  void onEventOccurred(Service service, ServiceStatus status) {
    if (status == ServiceStatus.found) {
      if (service.txt != null) {
        Map<String, String?> convertedData = service.txt!.map((key, value) {
          return MapEntry(
              key, value != null ? utf8.decode(value.toList()) : null);
        });
        GroupBean bean = GroupBean(
            name: service.name,
            type: service.type,
            port: service.port,
            host: service.host,
            attributes: Attributes.fromJson(convertedData));
        _groupProvider.addClient(bean);
      }
    } else if (status == ServiceStatus.lost) {
      if (service.txt != null) {
        Map<String, String?> convertedData = service.txt!.map((key, value) {
          return MapEntry(
              key, value != null ? utf8.decode(value.toList()) : null);
        });
        GroupBean bean = GroupBean(
            name: service.name,
            type: service.type,
            port: service.port,
            host: service.host,
            attributes: Attributes.fromJson(convertedData));
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
          _groupProvider.removeClient(bean);
        }
      }
    }

    notifyListeners();
  }
}
