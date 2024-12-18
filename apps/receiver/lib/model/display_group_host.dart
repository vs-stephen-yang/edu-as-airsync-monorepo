import 'package:display_flutter/model/display_group_mediator.dart';
import 'package:display_flutter/model/display_group_member_info.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'display_group_member.dart';

class DisplayGroupHost {
  final _members = <String, DisplayGroupMember>{};
  final DisplayGroupMediator _mediator;

  DisplayGroupHost(this._mediator);

  get members => _members;

  // Remove a member by their ID
  void removeMember(String memberId) {
    _members[memberId]?.stop();
    _members.remove(memberId);
  }

  // Add a member
  void addMember(GroupListItem item, DisplayGroupMemberInfo memberInfo,
      ProviderContainer? providerContainer) {
    final member = DisplayGroupMember(memberInfo, _mediator, onRejected: () {
      providerContainer?.read(groupProvider.notifier).addToRejectedList(item);
    }, onStopped: (bool stayOnList) {
      removeMember(item.id());
      if (!stayOnList) {
        providerContainer
            ?.read(groupProvider.notifier)
            .removeFromSelectedList(item);
      }
    });

    _members[item.id()] = member;
  }

  // Stop all members and clear the map
  void stop() {
    for (var member in _members.values) {
      member.stop();
    }
    _members.clear();
  }
}
