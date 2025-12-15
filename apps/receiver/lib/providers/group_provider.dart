import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BroadcastGroupLaunchType {
  onlyWhenCasting,
  allTheTime,
}

class GroupState {
  final List<GroupListItem> clients;
  final List<GroupListItem> selectedList;
  final List<GroupListItem> rejectedList;
  final List<Map<String, dynamic>> historySelectedList;
  final bool broadcastToGroup;
  final BroadcastGroupLaunchType broadcastGroupLaunchType;

  const GroupState({
    required this.clients,
    required this.selectedList,
    required this.rejectedList,
    required this.broadcastToGroup,
    required this.broadcastGroupLaunchType,
    required this.historySelectedList,
  });

  GroupState copyWith({
    List<GroupListItem>? clients,
    List<GroupListItem>? selectedList,
    List<GroupListItem>? rejectedList,
    List<Map<String, dynamic>>? historySelectedList,
    bool? broadcastToGroup,
    BroadcastGroupLaunchType? broadcastGroupLaunchType,
  }) {
    return GroupState(
      clients: clients ?? this.clients,
      selectedList: selectedList ?? this.selectedList,
      rejectedList: rejectedList ?? this.rejectedList,
      historySelectedList: historySelectedList ?? this.historySelectedList,
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
          rejectedList: [],
          historySelectedList: AppPreferences().groupSelectedList.toList(),
          broadcastToGroup: false,
          broadcastGroupLaunchType: BroadcastGroupLaunchType.onlyWhenCasting,
        ));

  void addClient(GroupListItem client) {
    if (client.id() == AppInstanceCreate().groupID) {
      return;
    }
    bool inHistory =
        state.historySelectedList.any((map) => map.containsKey(client.id()));
    if (inHistory) {
      state.selectedList.removeWhere((item) => item.id() == client.id());
      state = state.copyWith(selectedList: [...state.selectedList, client]);
    } else {
      state.clients
          .removeWhere((foundService) => foundService.id() == client.id());
      final updatedClients = _sortClientsByPriority([...state.clients, client]);
      state = state.copyWith(clients: updatedClients);
    }
  }

  void removeClient(GroupListItem client) {
    if (state.selectedList.any((item) => item.id() == client.id())) {
      state.selectedList.removeWhere((item) => item.id() == client.id());
      state = state.copyWith(
        selectedList: state.selectedList.toList(),
      );
    } else {
      state.clients
          .removeWhere((foundService) => foundService.id() == client.id());
      state = state.copyWith(
        selectedList: state.selectedList.toList(),
      );
    }
  }

  void clearClients() {
    state = state.copyWith(clients: [], selectedList: []);
  }

  List<GroupListItem> getClientList() {
    return [...state.selectedList, ...state.clients];
  }

  void organizeGroupList() {
    final historyList = AppPreferences().groupSelectedList.toList();
    final List<GroupListItem> selectedList = [];
    final List<GroupListItem> client = [];
    final List<GroupListItem> listenList = [
      ...state.selectedList,
      ...state.clients
    ];
    for (var element in listenList) {
      bool inHistory = historyList.any((map) => map.containsKey(element.id()));
      if (inHistory) {
        selectedList.add(element);
      } else {
        client.add(element);
      }
    }
    final sortedClients = _sortClientsByPriority(client);
    state = state.copyWith(
        clients: sortedClients,
        selectedList: selectedList,
        historySelectedList: historyList);
  }

  void addToSelectedList(GroupListItem client) {
    if (!state.selectedList.contains(client)) {
      if (state.selectedList.length >= 10) {
        state.selectedList.removeAt(0);
      }
      state.clients
          .removeWhere((foundService) => foundService.id() == client.id());
      final newSelectedList = [...state.selectedList, client];
      _addToHistorySelectedList(client);
      state = state.copyWith(
          selectedList: newSelectedList, clients: state.clients.toList());
    }
  }

  void removeFromSelectedList(GroupListItem client) {
    state.selectedList
        .removeWhere((foundService) => foundService.id() == client.id());
    final newSelectedList = state.selectedList.toList();
    _removeFromHistorySelectedList(client.id());
    final updatedClients = _sortClientsByPriority([...state.clients, client]);
    state = state.copyWith(
      selectedList: newSelectedList,
      clients: updatedClients,
    );
  }

  List<Map<String, dynamic>> get historySelectedList =>
      state.historySelectedList;

  void _addToHistorySelectedList(GroupListItem client) {
    if (!state.historySelectedList.any((map) => map.containsKey(client.id()))) {
      if (state.historySelectedList.length >= 10) {
        state.historySelectedList.removeAt(0);
      }
      state.historySelectedList.add({client.id(): client.toJson()});
    }
  }

  void _removeFromHistorySelectedList(String clientId) {
    state.historySelectedList.removeWhere((map) => map.containsKey(clientId));
  }

  // 對客戶端列表進行排序：手動添加的設備（viaIp）優先顯示在前面
  List<GroupListItem> _sortClientsByPriority(List<GroupListItem> clients) {
    final viaIpClients = clients.where((c) => c.viaIp()).toList();
    final discoveredClients = clients.where((c) => !c.viaIp()).toList();
    return [...viaIpClients, ...discoveredClients];
  }

  void clearSelectedList() {
    state = state.copyWith(selectedList: []);
  }

  List<GroupListItem> get selectedList => state.selectedList;

  List<GroupListItem> get rejectedList => state.rejectedList;

  void addToRejectedList(GroupListItem client) {
    if (!state.rejectedList.any((item) => item.id() == client.id())) {
      if (client.invitedState() !=
          InvitedToGroupOption.autoAccept.value.toString()) {
        final newList = [...state.rejectedList, client];
        state = state.copyWith(rejectedList: newList);
      }
    }
  }

  void removeFormRejectedList(GroupListItem client) {
    state.rejectedList.removeWhere((item) => item.id() == client.id());
    final newList = state.rejectedList.toList();
    state = state.copyWith(rejectedList: newList);
  }

  void setBroadcastToGroup(bool value) {
    state = state.copyWith(broadcastToGroup: value);
  }

  bool get broadcastToGroup => state.broadcastToGroup;

  void setBroadcastGroupLaunchType(BroadcastGroupLaunchType type) {
    state = state.copyWith(broadcastGroupLaunchType: type);
  }

  BroadcastGroupLaunchType get broadcastGroupLaunchType =>
      state.broadcastGroupLaunchType;

  void toggleFavorite(GroupListItem client) {
    final List<Map<String, dynamic>> favoriteList =
        AppPreferences().favoriteList.toList();

    // 檢查是否已經在 favorite 列表中
    final index = favoriteList.indexWhere((map) => map.containsKey(client.id()));

    if (index != -1) {
      // 已存在，移除
      favoriteList.removeAt(index);
    } else {
      // 不存在，新增
      // 建立新的 GroupBean 並設定 favorite = true
      final favoriteClient = GroupBean.fromJson(
        client.toJson(),
        favorite: true,
      );
      favoriteList.add({client.id(): favoriteClient.toJson()});
    }

    AppPreferences().setFavoriteList(favoriteList);

    // 更新當前的 client 列表中的 favorite 狀態
    _updateClientFavoriteState();
  }

  bool isFavorite(String clientId) {
    final favoriteList = AppPreferences().favoriteList;
    return favoriteList.any((map) => map.containsKey(clientId));
  }

  void _updateClientFavoriteState() {
    // 這個方法會觸發 UI 更新
    state = state.copyWith(
      clients: state.clients.toList(),
      selectedList: state.selectedList.toList(),
    );
  }

  void loadFavoriteDevices() {
    final favoriteList = AppPreferences().favoriteList;
    final List<GroupListItem> favoriteClients = [];

    for (var map in favoriteList) {
      map.forEach((key, value) {
        try {
          final client = GroupBean.fromJson(value, favorite: true);
          // 排除自己和已經存在的設備
          if (client.id() != AppInstanceCreate().groupID &&
              !state.selectedList.any((item) => item.id() == client.id()) &&
              !state.clients.any((item) => item.id() == client.id())) {
            favoriteClients.add(client);
          }
        } catch (e) {
          // 處理解析錯誤
          print('Error loading favorite device: $e');
        }
      });
    }

    // 將 favorite 設備加入到 clients 列表
    if (favoriteClients.isNotEmpty) {
      final updatedClients = _sortClientsByPriority([
        ...favoriteClients,
        ...state.clients,
      ]);
      state = state.copyWith(clients: updatedClients);
    }
  }

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
