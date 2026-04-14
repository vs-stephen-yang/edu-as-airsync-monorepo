import 'package:display_flutter/model/display_group_mediator.dart';
import 'package:display_flutter/model/display_group_member_info.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/log_uploader_with_cooldown.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'display_group_member.dart';

class DisplayGroupHost {
  final _members = <String, DisplayGroupMember>{};
  final _rejectMemberOption = <String, InvitedToGroupOption>{};
  final DisplayGroupMediator _mediator;
  final LogUploaderWithCooldown _hostFpsZeroLogUploader;

  DisplayGroupHost(this._mediator, this._hostFpsZeroLogUploader);

  get members => _members;

  // Remove a member by their ID
  void removeMember(String memberId) {
    log.info('DisplayGroupHost: Removing member $memberId');
    _members[memberId]?.stop();
    _members.remove(memberId);
  }

  // Add a member
  void addMember(GroupListItem item, DisplayGroupMemberInfo memberInfo,
      ProviderContainer? providerContainer) {
    if (_rejectMemberOption.containsKey(item.id())) {
      log.info('DisplayGroupHost: Member ${item.id()} is in reject list, skip adding');
      return;
    }
    if (item.invitedState() == InvitedToGroupOption.ignore.value.toString()) {
      _rejectMemberOption[item.id()] = InvitedToGroupOption.ignore;
    } else if (item.invitedState() ==
        InvitedToGroupOption.notifyMe.value.toString()) {
      if (_rejectMemberOption.containsKey(item.id()) &&
          _rejectMemberOption[item.id()] == InvitedToGroupOption.ignore) {
        _rejectMemberOption.remove(item.id());
      }
    }

    final member = DisplayGroupMember(
        memberInfo, _mediator, _hostFpsZeroLogUploader, onRejected: () {
      _rejectMemberOption[item.id()] =
          (item.invitedState() == InvitedToGroupOption.ignore.value.toString())
              ? InvitedToGroupOption.ignore
              : InvitedToGroupOption.notifyMe;
      providerContainer?.read(groupProvider.notifier).addToRejectedList(item);
    }, onStopped: (bool stayOnList) {
      removeMember(item.id());
      if (!stayOnList) {
        providerContainer
            ?.read(groupProvider.notifier)
            .removeFromSelectedList(item);
      }
    });

    log.info('DisplayGroupHost: Adding member ${item.id()}');
    _members[item.id()] = member;
  }

  // Stop all members and clear the map
  void stop() {
    log.info('DisplayGroupHost: Stopping all ${_members.length} members');
    for (var member in _members.values) {
      member.stop();
    }
    _members.clear();
  }

  void resetCastRejectMember() {
    _rejectMemberOption.clear();
  }
}
