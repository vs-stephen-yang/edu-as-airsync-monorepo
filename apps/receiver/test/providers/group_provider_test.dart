import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late GroupProvider provider;

  setUp(() async {
    // 初始化 SharedPreferences（清空所有數據）
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.ensureInitialized();

    // 清空 favoriteList 和 selectedList
    AppPreferences().setFavoriteList([]);
    AppPreferences().setGroupSelectedList([]);

    provider = GroupProvider();
  });

  group('設備列表排序優先級測試', () {
    test('優先級 0: 找不到的設備應該在最上面', () {
      // 創建測試設備
      final device1 = _createDevice(id: '1', name: 'Device 1', viaIp: true);
      final device2 = _createDevice(
          id: '2', name: '192.168.1.100', viaIp: true, ipNotFind: true);
      final device3 = _createDevice(id: '3', name: 'Device 3', viaIp: false);

      // 添加設備
      provider.addClient(device1);
      provider.addClient(device2);
      provider.addClient(device3);

      final list = provider.getClientList();

      // 找不到的設備應該在最上面
      expect(list.first.id(), '2');
      expect(list.first.ipNotFind(), true);
    });

    test('優先級 0: 多個找不到的設備', () {
      // 按順序添加找不到的設備
      final device1 = _createDevice(
          id: '1', name: '192.168.1.100', viaIp: true, ipNotFind: true);
      final device2 = _createDevice(
          id: '2', name: '192.168.1.101', viaIp: true, ipNotFind: true);
      final device3 = _createDevice(
          id: '3', name: '192.168.1.102', viaIp: true, ipNotFind: true);

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addClient(device3);

      final list = provider.getClientList();

      // 驗證所有找不到的設備都在列表中
      expect(list.length, 3);
      expect(list.where((d) => d.ipNotFind()).length, 3);
    });

    test('優先級 1: 已勾選的設備在找不到設備之後', () {
      final notFoundDevice = _createDevice(
          id: '1', name: '192.168.1.100', viaIp: true, ipNotFind: true);
      final normalDevice = _createDevice(id: '2', name: 'Device 2');

      provider.addClient(notFoundDevice);
      provider.addClient(normalDevice);
      provider.addToSelectedList(normalDevice);

      final list = provider.getClientList();

      // 順序：找不到 -> 已勾選 -> 其他
      expect(list[0].id(), '1'); // 找不到（優先級 0）
      expect(list[1].id(), '2'); // 已勾選（優先級 1）
    });

    test('優先級 0: not found 設備即使在 selectedList 中也要排在最前面', () {
      // 模擬場景：一個設備之前被勾選過（在 history 中），但現在變成 not found
      final notFoundDevice = _createDevice(
          id: '1', name: '192.168.1.100', viaIp: true, ipNotFind: true);
      final normalDevice = _createDevice(id: '2', name: 'Device 2');

      // 先將 notFoundDevice 加入 history
      AppPreferences().setGroupSelectedList([
        {'1': notFoundDevice.toJson()}
      ]);
      provider = GroupProvider(); // 重新初始化以載入 history

      // 添加設備（因為在 history 中，會被加到 selectedList）
      provider.addClient(notFoundDevice);
      provider.addClient(normalDevice);
      provider.addToSelectedList(normalDevice);

      final list = provider.getClientList();

      // not found 設備應該在最前面，即使它在 selectedList 中
      expect(list[0].id(), '1'); // not found（優先級 0）
      expect(list[0].ipNotFind(), true);
      expect(list[1].id(), '2'); // 已勾選（優先級 1）
    });

    test('優先級 1: 已勾選設備，最新勾選的在上面', () {
      final device1 = _createDevice(id: '1', name: 'Device 1');
      final device2 = _createDevice(id: '2', name: 'Device 2');
      final device3 = _createDevice(id: '3', name: 'Device 3');

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addClient(device3);

      // 依序勾選
      provider.addToSelectedList(device1);
      provider.addToSelectedList(device2);
      provider.addToSelectedList(device3);

      final list = provider.getClientList();

      // 最新勾選的在上面
      expect(list[0].id(), '3'); // 最新勾選
      expect(list[1].id(), '2');
      expect(list[2].id(), '1'); // 最早勾選
    });

    test('優先級 2: 收藏且上線的設備按 favoriteTimestamp 排序', () async {
      final device1 = _createDevice(
          id: '1', name: 'Device 1', favorite: true, favoriteTimestamp: 1000);
      final device2 = _createDevice(
          id: '2', name: 'Device 2', favorite: true, favoriteTimestamp: 3000);
      final device3 = _createDevice(
          id: '3', name: 'Device 3', favorite: true, favoriteTimestamp: 2000);

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addClient(device3);

      final list = provider.getClientList();

      // 按 favoriteTimestamp 降序（最新的在上）
      expect(list[0].id(), '2'); // 3000 最新
      expect(list[1].id(), '3'); // 2000
      expect(list[2].id(), '1'); // 1000 最早
    });

    test('優先級 4: 手動輸入未收藏設備', () {
      final device1 =
          _createDevice(id: '1', name: '192.168.1.100', viaIp: true);
      final device2 =
          _createDevice(id: '2', name: '192.168.1.101', viaIp: true);
      final device3 =
          _createDevice(id: '3', name: '192.168.1.102', viaIp: true);

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addClient(device3);

      final list = provider.getClientList();

      // 驗證所有手動輸入設備都在列表中
      expect(list.length, 3);
      expect(list.where((d) => d.viaIp() && !d.favorite()).length, 3);
    });

    test('優先級 5: 自動發現設備', () {
      final device1 = _createDevice(id: '1', name: 'Device 1', viaIp: false);
      final device2 = _createDevice(id: '2', name: 'Device 2', viaIp: false);
      final device3 = _createDevice(id: '3', name: 'Device 3', viaIp: false);

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addClient(device3);

      final list = provider.getClientList();

      // 驗證所有自動發現設備都在列表中
      expect(list.length, 3);
      expect(list.where((d) => !d.viaIp() && !d.favorite()).length, 3);
    });

    test('完整排序：所有優先級混合', () {
      // 創建各種類型的設備
      final notFound1 = _createDevice(
          id: 'nf1', name: '192.168.1.100', viaIp: true, ipNotFind: true);
      final notFound2 = _createDevice(
          id: 'nf2', name: '192.168.1.101', viaIp: true, ipNotFind: true);

      final selected1 = _createDevice(id: 's1', name: 'Selected 1');
      final selected2 = _createDevice(id: 's2', name: 'Selected 2');

      final favoriteOnline = _createDevice(
          id: 'fo',
          name: 'Favorite Online',
          favorite: true,
          favoriteTimestamp: 2000);

      final manualNotFavorite =
          _createDevice(id: 'mnf', name: '192.168.1.102', viaIp: true);

      final autoDiscovered =
          _createDevice(id: 'ad', name: 'Auto Discovered', viaIp: false);

      // 添加設備
      provider.addClient(autoDiscovered);
      provider.addClient(manualNotFavorite);
      provider.addClient(favoriteOnline);
      provider.addClient(selected1);
      provider.addClient(selected2);
      provider.addClient(notFound1);
      provider.addClient(notFound2);

      // 勾選設備
      provider.addToSelectedList(selected1);
      provider.addToSelectedList(selected2);

      final list = provider.getClientList();

      // 驗證總數
      expect(list.length, 7);

      // 驗證優先級 0: 找不到的設備在最前面
      final notFoundDevices = list.where((d) => d.ipNotFind()).toList();
      expect(notFoundDevices.length, 2);
      expect(list.indexOf(notFoundDevices.first), lessThan(2));

      // 驗證優先級 1: 已勾選的設備（不含 notFound）
      final selectedDevices = list
          .where((d) => provider.selectedList.contains(d) && !d.ipNotFind())
          .toList();
      expect(selectedDevices.length, 2);
      expect(selectedDevices[0].id(), 's2'); // 最新勾選
      expect(selectedDevices[1].id(), 's1');

      // 驗證優先級 2: 收藏且上線
      final favoriteDevices =
          list.where((d) => d.favorite() && !d.ipNotFind()).toList();
      expect(favoriteDevices.length, 1);
      expect(favoriteDevices.first.id(), 'fo');

      // 驗證排序：找不到 -> 已勾選 -> 收藏 -> 手動 -> 自動
      // 找不到的設備應該在已勾選（非 notFound）之前
      final nfIndex = list.indexWhere((d) => d.ipNotFind());
      final selectedIndex = list.indexWhere(
          (d) => provider.selectedList.contains(d) && !d.ipNotFind());
      expect(nfIndex, lessThan(selectedIndex));
    });
  });

  group('勾選功能測試', () {
    test('勾選設備後，設備從 clients 移到 selectedList', () {
      final device = _createDevice(id: '1', name: 'Device 1');
      provider.addClient(device);

      expect(provider.selectedList.length, 0);
      expect(provider.state.clients.length, 1);

      provider.addToSelectedList(device);

      expect(provider.selectedList.length, 1);
      expect(provider.state.clients.length, 0);
      expect(provider.selectedList.first.id(), '1');
    });

    test('取消勾選後，設備回到 clients 並重新排序', () {
      final device1 = _createDevice(id: '1', name: 'Device 1', viaIp: true);
      final device2 = _createDevice(id: '2', name: 'Device 2', viaIp: false);

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addToSelectedList(device1);

      expect(provider.selectedList.length, 1);
      expect(provider.state.clients.length, 1);

      provider.removeFromSelectedList(device1);

      expect(provider.selectedList.length, 0);
      expect(provider.state.clients.length, 2);

      // 驗證排序：viaIp 的在前面
      final list = provider.getClientList();
      expect(list[0].id(), '1'); // viaIp
      expect(list[1].id(), '2'); // auto discovered
    });

    test('勾選上限為 10 個，超過時移除最早勾選的', () {
      // 創建 11 個設備
      for (int i = 1; i <= 11; i++) {
        final device = _createDevice(id: '$i', name: 'Device $i');
        provider.addClient(device);
        provider.addToSelectedList(device);
      }

      // 應該只有 10 個
      expect(provider.selectedList.length, 10);

      final list = provider.getClientList();

      // 最早勾選的（Device 1）應該被移除
      expect(list.any((d) => d.id() == '1'), false);

      // Device 2-11 應該存在，且 11 在最上面（最新勾選）
      expect(list.first.id(), '11');
      expect(list.any((d) => d.id() == '2'), true);
    });

    test('重複勾選同一設備不會重複添加', () {
      final device = _createDevice(id: '1', name: 'Device 1');
      provider.addClient(device);

      provider.addToSelectedList(device);
      provider.addToSelectedList(device);

      expect(provider.selectedList.length, 1);
    });
  });

  group('收藏功能測試', () {
    test('toggleFavorite 會記錄 favoriteTimestamp', () async {
      final device = _createDevice(id: '1', name: 'Device 1');
      provider.addClient(device);

      final beforeTimestamp = DateTime.now().millisecondsSinceEpoch;

      provider.toggleFavorite(device);

      final afterTimestamp = DateTime.now().millisecondsSinceEpoch;

      // 檢查 favoriteList 中的時間戳
      final favoriteList = AppPreferences().favoriteList;
      expect(favoriteList.length, 1);

      final savedData = favoriteList.first['1'];
      final favoriteTimestamp = savedData['service.favoriteTimestamp'];

      expect(favoriteTimestamp, isNotNull);
      expect(favoriteTimestamp, greaterThanOrEqualTo(beforeTimestamp));
      expect(favoriteTimestamp, lessThanOrEqualTo(afterTimestamp));
    });

    test('toggleFavorite 再次調用會移除收藏', () {
      final device = _createDevice(id: '1', name: 'Device 1');
      provider.addClient(device);

      // 確認初始沒有收藏
      expect(provider.isFavorite('1'), false);

      // 第一次調用：添加收藏
      provider.toggleFavorite(device);
      expect(provider.isFavorite('1'), true);

      // 第二次調用：移除收藏
      provider.toggleFavorite(device);
      expect(provider.isFavorite('1'), false);
    });

    test('收藏的設備會按 favoriteTimestamp 排序', () async {
      // 手動創建有不同 favoriteTimestamp 的設備
      final device1 = _createDevice(
          id: '1', name: 'Device 1', favorite: true, favoriteTimestamp: 1000);
      final device2 = _createDevice(
          id: '2', name: 'Device 2', favorite: true, favoriteTimestamp: 3000);
      final device3 = _createDevice(
          id: '3', name: 'Device 3', favorite: true, favoriteTimestamp: 2000);

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addClient(device3);

      final list = provider.getClientList();

      // 最新收藏的在上面
      final favoriteDevices = list.where((d) => d.favorite()).toList();
      expect(favoriteDevices[0].id(), '2'); // 3000
      expect(favoriteDevices[1].id(), '3'); // 2000
      expect(favoriteDevices[2].id(), '1'); // 1000
    });
  });

  group('邊界情況測試', () {
    test('空列表不會出錯', () {
      final list = provider.getClientList();
      expect(list, isEmpty);
    });

    test('只有找不到的設備', () {
      final device = _createDevice(
          id: '1', name: '192.168.1.100', viaIp: true, ipNotFind: true);
      provider.addClient(device);

      final list = provider.getClientList();
      expect(list.length, 1);
      expect(list.first.ipNotFind(), true);
    });

    test('只有已勾選的設備', () {
      final device = _createDevice(id: '1', name: 'Device 1');
      provider.addClient(device);
      provider.addToSelectedList(device);

      final list = provider.getClientList();
      expect(list.length, 1);
      expect(list.first.id(), '1');
    });

    test('clearClients 會清空所有設備', () {
      final device1 = _createDevice(id: '1', name: 'Device 1');
      final device2 = _createDevice(id: '2', name: 'Device 2');

      provider.addClient(device1);
      provider.addClient(device2);
      provider.addToSelectedList(device1);

      provider.clearClients();

      expect(provider.getClientList(), isEmpty);
      expect(provider.selectedList, isEmpty);
    });
  });
}

// 輔助函數：創建測試設備
GroupBean _createDevice({
  required String id,
  required String name,
  bool viaIp = false,
  bool favorite = false,
  bool ipNotFind = false,
  int? favoriteTimestamp,
}) {
  final attributes = Attributes(
    id: id,
    fn: name,
    dc: 'TEST',
    ip: viaIp ? name : '192.168.1.1',
    igo: '1',
    mc: '1',
    ver: '1.0',
  );

  return GroupBean(
    name: 'test-service-$id',
    type: '_airsync._tcp',
    port: 5000,
    host: '192.168.1.1',
    attributes: attributes,
    viaIp: viaIp,
    favorite: favorite,
    notFind: ipNotFind,
    favoriteTimestamp: favoriteTimestamp,
  );
}
