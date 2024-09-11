import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/services/display_group_member.dart';
import 'package:display_flutter/services/display_group_member_info.dart';

class DisplayGroupHost {
  final _members = <DisplayGroupMember>[];

  final Future<RemoteScreenConnector> Function(
    Channel,
    StartRemoteScreenMessage,
  ) _createRemoteScreenConnector;

  DisplayGroupHost(
    this._createRemoteScreenConnector,
  );

  void addMember(DisplayGroupMemberInfo memberInfo) {
    final member = DisplayGroupMember(
      memberInfo,
      _createRemoteScreenConnector,
    );

    _members.add(member);
  }

  void stop() {
    for (var member in _members) {
      member.stop();
    }
    _members.clear();
  }
}
