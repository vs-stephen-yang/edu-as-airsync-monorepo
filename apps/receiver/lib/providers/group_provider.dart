import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/utility/log.dart';
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
  static int groupMaximum = 10;

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
    bool inHistory = state.historySelectedList
        .any((map) => _matchesHistoryEntry(client, map));
    bool isDuplicate(GroupListItem item) =>
        item.id() == client.id() ||
        (client.displayCode().isNotEmpty &&
            item.displayCode() == client.displayCode());

    if (inHistory) {
      final newSelectedList =
          state.selectedList.where((item) => !isDuplicate(item)).toList();
      state = state.copyWith(selectedList: [...newSelectedList, client]);
    } else {
      final filteredClients =
          state.clients.where((item) => !isDuplicate(item)).toList();
      final updatedClients =
          _sortClientsByPriority([...filteredClients, client]);
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
    // 合併所有設備
    final allDevices = [
      ...state.selectedList,
      ...state.clients,
    ];

    // 優先級 0: 找不到的設備（最優先，無論是否已勾選）
    final notFoundDevices =
        allDevices.where((c) => c.ipNotFind()).toList().reversed; // 最新添加的在上面

    // 優先級 1: 已勾選且不是 not found
    final selectedDevices = state.selectedList
        .where((c) => !c.ipNotFind())
        .toList()
        .reversed; // 最新勾選的在上

    // 優先級 2-5: clients 中不是 not found 的
    final otherClients = state.clients.where((c) => !c.ipNotFind()).toList();

    final result = [
      ...notFoundDevices, // 優先級 0: 手動輸入找不到（最優先）
      ...selectedDevices, // 優先級 1: 已勾選（不含 not found）
      ...otherClients, // 優先級 2-5（已在 _sortClientsByPriority 中排序）
    ];

    log.info(
        '📋 [GroupProvider] getClientList() returned ${result.length} devices');
    log.info(
        '   - notFound: ${notFoundDevices.length}, selected: ${selectedDevices.length}, others: ${otherClients.length}');
    return result;
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
      bool inHistory =
          historyList.any((map) => _matchesHistoryEntry(element, map));
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
      if (state.selectedList.length >= groupMaximum) {
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
    // Remove any existing entry with same id or same displayCode
    // (handles clear data case where id changes but displayCode stays the same)
    state.historySelectedList
        .removeWhere((map) => _matchesHistoryEntry(client, map));
    if (state.historySelectedList.length >= groupMaximum) {
      state.historySelectedList.removeAt(0);
    }
    state.historySelectedList.add({client.id(): client.toJson()});
  }

  void _removeFromHistorySelectedList(String clientId) {
    state.historySelectedList.removeWhere((map) => map.containsKey(clientId));
  }

  /// Returns true if [item] matches the given history [map] entry,
  /// by ID or by displayCode (to handle clear-data ID changes).
  bool _matchesHistoryEntry(GroupListItem item, Map<String, dynamic> map) {
    if (map.containsKey(item.id())) return true;
    if (item.displayCode().isEmpty) return false;
    return map.values.any((data) =>
        (data['service.attributes'] as Map?)?['dc'] == item.displayCode());
  }

  // 對客戶端列表進行排序：實現完整的 6 級排序邏輯
  // ⚠️ 注意：此函數只對未勾選的設備（state.clients）進行排序
  // 手動輸入找不到的設備（優先級 0）和已勾選的設備（優先級 1）在 getClientList() 中處理
  List<GroupListItem> _sortClientsByPriority(List<GroupListItem> clients) {
    // 優先級 0: 手動輸入後找不到（最優先）
    final notFoundDevices = clients
        .where((c) => c.viaIp() && c.ipNotFind())
        .toList()
        .reversed; // 最新添加的在上面

    // 優先級 2: 收藏且顯示上線（未勾選）
    final favoriteOnline = clients
        .where((c) => c.favorite() && !_isUnavailable(c) && !c.ipNotFind())
        .toList()
      ..sort((a, b) => b.favoriteTimestamp().compareTo(a.favoriteTimestamp()));

    // 優先級 3: 收藏但顯示未上線（未勾選）
    final favoriteOffline = clients
        .where((c) => c.favorite() && _isUnavailable(c) && !c.ipNotFind())
        .toList()
      ..sort((a, b) => b.favoriteTimestamp().compareTo(a.favoriteTimestamp()));

    // 優先級 4: 手動輸入 + 未收藏 + 已上線（未勾選）
    final manualNotFavorite = clients
        .where((c) =>
            c.viaIp() && !c.favorite() && !_isUnavailable(c) && !c.ipNotFind())
        .toList()
        .reversed; // 最新添加的在上面

    // 優先級 5: 自動發現（未勾選）
    final autoDiscovered = clients
        .where((c) => !c.viaIp() && !c.favorite())
        .toList()
        .reversed; // 最新發現的在上面

    return [
      ...notFoundDevices, // 優先級 0: 手動輸入找不到
      ...favoriteOnline, // 優先級 2: 收藏且上線
      ...favoriteOffline, // 優先級 3: 收藏但未上線
      ...manualNotFavorite, // 優先級 4: 手動輸入未收藏
      ...autoDiscovered, // 優先級 5: 自動發現
    ];
  }

  // 判斷設備是否不可用（unavailable）
  // 根據文檔：unavailable = invitedState==2 || (unsupportedMulticast && useMulticast) || ipNotFind
  bool _isUnavailable(GroupListItem client) {
    // 注意：這裡無法存取 AppSettings context
    // 目前簡化判斷邏輯，只檢查 invitedState 和 ipNotFind
    // unsupportedMulticast && useMulticast 的判斷在 UI 層處理
    // 這不會影響大部分情況的排序，因為：
    // 1. 場景 5, 7: 舊設備 + MC 關閉 -> unavailable=false -> 正確歸類到優先級 2
    // 2. 場景 6, 8: 舊設備 + MC 開啟 -> 需要 UI 層協助判斷，但會被歸類到優先級 5（自動發現未收藏）
    return client.invitedState() == '2' || client.ipNotFind();
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
    final index =
        favoriteList.indexWhere((map) => map.containsKey(client.id()));

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

      // 🔑 設定收藏時間戳（會持久化保存）
      final clientData = favoriteClient.toJson();
      clientData['service.favoriteTimestamp'] =
          DateTime.now().millisecondsSinceEpoch;

      favoriteList.add({client.id(): clientData});
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
    // 從 favoriteList 讀取最新的收藏狀態
    final favoriteList = AppPreferences().favoriteList;

    // 更新 clients 和 selectedList 中的設備狀態
    final updatedClients = state.clients.map((client) {
      final favoriteData = favoriteList.firstWhere(
        (map) => map.containsKey(client.id()),
        orElse: () => {},
      );

      if (favoriteData.isNotEmpty) {
        // 設備已被收藏，需要更新其狀態
        final data = favoriteData[client.id()];
        return GroupBean.fromJson(
          {...client.toJson(), ...data},
          favorite: true,
        );
      } else {
        // 設備未被收藏或已取消收藏
        if (client.favorite()) {
          // 之前是收藏的，現在需要取消
          return GroupBean.fromJson(
            client.toJson(),
            favorite: false,
          );
        }
        return client;
      }
    }).toList();

    final updatedSelectedList = state.selectedList.map((client) {
      final favoriteData = favoriteList.firstWhere(
        (map) => map.containsKey(client.id()),
        orElse: () => {},
      );

      if (favoriteData.isNotEmpty) {
        final data = favoriteData[client.id()];
        return GroupBean.fromJson(
          {...client.toJson(), ...data},
          favorite: true,
        );
      } else {
        if (client.favorite()) {
          return GroupBean.fromJson(
            client.toJson(),
            favorite: false,
          );
        }
        return client;
      }
    }).toList();

    // 重新排序 clients 列表
    final sortedClients = _sortClientsByPriority(updatedClients);

    // 更新狀態
    state = state.copyWith(
      clients: sortedClients,
      selectedList: updatedSelectedList,
    );
  }

  Future<void> loadFavoriteDevices() async {
    final favoriteList = AppPreferences().favoriteList;
    final List<GroupListItem> favoriteClients = [];

    for (var map in favoriteList) {
      for (var value in map.values) {
        try {
          GroupListItem client = GroupBean.fromJson(value, favorite: true);
          // 執行 UDP 查詢和添加邏輯
          try {
            client = GroupBean.fromJson(
              await UdpResponder.askPeerViaUdp(client.ip()),
              favorite: true,
              offline: false,
              viaIp: client.viaIp(),
            );
          } catch (a) {
            // 舊版本沒有udp，會使用ping的方式確認
            final offline = await UdpResponder.checkConnection(client.ip());
            client =
                GroupBean.fromJson(value, favorite: true, offline: offline);
          }

          // 排除自己和已經存在的設備
          if (client.id() != AppInstanceCreate().groupID &&
              !state.selectedList.any((item) => item.id() == client.id()) &&
              !state.clients.any((item) => item.id() == client.id())) {
            favoriteClients.add(client);
          } else {
            final selectedIndex = state.selectedList
                .indexWhere((item) => item.id() == client.id());
            if (selectedIndex != -1) {
              state.selectedList[selectedIndex] = client;
            }
            final clientsIndex =
                state.clients.indexWhere((item) => item.id() == client.id());
            if (clientsIndex != -1) {
              state.clients[clientsIndex] = client;
            }
          }
        } catch (e) {
          // 處理解析錯誤
          log.warning('Error loading favorite device: $e');
        }
      }
    }

    // 將 favorite 設備加入到 clients 列表
    final updatedClients = _sortClientsByPriority([
      ...favoriteClients,
      ...state.clients,
    ]);
    state = state.copyWith(clients: updatedClients);
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
