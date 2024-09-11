import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/services/display_group_member.dart';
import 'package:display_flutter/services/display_group_member_info.dart';

class DisplayGroupHost {
  final _members = <String, DisplayGroupMember>{};

  final Future<RemoteScreenConnector> Function(
    Channel,
    StartRemoteScreenMessage,
  ) _createRemoteScreenConnector;

  DisplayGroupHost(
    this._createRemoteScreenConnector,
  );

  // Remove a member by their ID
  void removeMember(String memberId) {
    _members[memberId]?.stop();
    _members.remove(memberId);
  }

  // Add a member
  void addMember(String memberId, DisplayGroupMemberInfo memberInfo) {
    final member = DisplayGroupMember(
      memberInfo,
      _createRemoteScreenConnector,
    );

    _members[memberId] = member;
  }

  // Stop all members and clear the map
  void stop() {
    for (var member in _members.values) {
      member.stop();
    }
    _members.clear();
  }
}
