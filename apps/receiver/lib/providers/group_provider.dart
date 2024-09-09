import 'package:display_flutter/model/group_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BroadcastGroupLaunchType {
  onlyWhenCasting,
  allTheTime,
}

class GroupState {
  final List<GroupListItem> clients;
  final List<GroupListItem> selectedList;
  final bool broadcastToGroup;
  final BroadcastGroupLaunchType broadcastGroupLaunchType;

  const GroupState({
    required this.clients,
    required this.selectedList,
    required this.broadcastToGroup,
    required this.broadcastGroupLaunchType,
  });

  GroupState copyWith({
    List<GroupListItem>? clients,
    List<GroupListItem>? selectedList,
    bool? broadcastToGroup,
    BroadcastGroupLaunchType? broadcastGroupLaunchType,
  }) {
    return GroupState(
      clients: clients ?? this.clients,
      selectedList: selectedList ?? this.selectedList,
      broadcastToGroup: broadcastToGroup ?? this.broadcastToGroup,
      broadcastGroupLaunchType:
          broadcastGroupLaunchType ?? this.broadcastGroupLaunchType,
    );
  }
}

class GroupProvider extends StateNotifier<GroupState> {
  GroupProvider()
      : super(GroupState(
          clients: [],
          selectedList: [],
          broadcastToGroup: false,
          broadcastGroupLaunchType: BroadcastGroupLaunchType.onlyWhenCasting,
        ));

  void addClient(GroupListItem client) {
    state = state.copyWith(clients: [...state.clients, client]);
  }

  void removeClient(GroupListItem client) {
    state = state.copyWith(
      clients:
          state.clients.where((element) => element.id != client.id).toList(),
      selectedList: state.selectedList
          .where((element) => element.id != client.id)
          .toList(),
    );
  }

  void clearClients() {
    state = state.copyWith(clients: [], selectedList: []);
  }

  GroupListItem getListenClient(int index) {
    return state.clients[index];
  }

  int getListenListSize() {
    return state.clients.length;
  }

  void addToSelectedList(GroupListItem client) {
    if (!state.selectedList.contains(client)) {
      state = state.copyWith(selectedList: [...state.selectedList, client]);
    }
  }

  void removeFromSelectedList(GroupListItem client) {
    state = state.copyWith(
      selectedList: state.selectedList
          .where((element) => element.id != client.id)
          .toList(),
    );
  }

  void clearSelectedList() {
    state = state.copyWith(selectedList: []);
  }

  List<GroupListItem> get selectedList => state.selectedList;

  void setBroadcastToGroup(bool value) {
    state = state.copyWith(broadcastToGroup: value);
  }

  bool get broadcastToGroup => state.broadcastToGroup;

  void setBroadcastGroupLaunchType(BroadcastGroupLaunchType type) {
    state = state.copyWith(broadcastGroupLaunchType: type);
  }

  BroadcastGroupLaunchType get broadcastGroupLaunchType =>
      state.broadcastGroupLaunchType;

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      broadcastToGroup: prefs.getBool('broadcastToGroup') ?? false,
      broadcastGroupLaunchType: BroadcastGroupLaunchType.values.byName(
        prefs.getString('broadcastGroupLaunchType') ??
            BroadcastGroupLaunchType.onlyWhenCasting.name,
      ),
    );
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('broadcastToGroup', state.broadcastToGroup);
    await prefs.setString(
        'broadcastGroupLaunchType', state.broadcastGroupLaunchType.name);
  }
}

final groupProvider = StateNotifierProvider<GroupProvider, GroupState>((ref) {
  return GroupProvider();
});
