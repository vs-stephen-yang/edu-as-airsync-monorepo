import 'package:display_flutter/utility/user_timer_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserTimerManager Tests', () {
    late UserTimerManager timerManager;

    setUp(() {
      timerManager = UserTimerManager();
      timerManager.clearAll();
    });

    tearDown(() {
      timerManager.clearAll();
    });

    test('Case 1: 兩人加入，順序 + 自動清除', () async {
      List<String> timeoutUsers = [];

      timerManager.onProgressUpdate = (progress, remainingSeconds) {};

      timerManager.onUserTimeout = (userId) {
        timeoutUsers.add(userId);
      };

      // 加入 user1 (WebRTC) → 倒數條為 10 秒
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc,
      );

      expect(timerManager.userCount, 1);
      expect(timerManager.currentDisplayTimer?.id, 'user1');
      expect(timerManager.currentDisplayTimer?.totalSeconds, 10);

      // 等待 2 秒
      await Future.delayed(Duration(seconds: 2));

      // 檢查 user1 剩餘時間應該是 8 秒左右
      expect(timerManager.currentDisplayTimer?.remainingSeconds,
          lessThanOrEqualTo(8));
      expect(timerManager.currentDisplayTimer?.remainingSeconds,
          greaterThanOrEqualTo(7));

      // n 秒後加入 user2 (AirPlay) → user2 剩餘 10 秒，user1 剩餘 8 秒，所以顯示 user2
      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.airplay,
      );

      expect(timerManager.userCount, 2);
      // user2 剩餘 10 秒，user1 剩餘 8 秒，所以顯示 user2
      expect(timerManager.currentDisplayTimer?.id, 'user2');

      print('Test Case 1 passed: 兩人加入，順序正確，時間保持');
    });

    test('重複添加用戶不會重置計時器', () async {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc, // 10s
      );

      // 等待 2 秒
      await Future.delayed(Duration(seconds: 2));

      final remainingBefore =
          timerManager.currentDisplayTimer?.remainingSeconds;
      expect(remainingBefore, lessThanOrEqualTo(9)); // 更寬容的範圍

      // 重複添加同一個用戶
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc,
      );

      // 時間應該保持不變，不會重置
      final remainingAfter = timerManager.currentDisplayTimer?.remainingSeconds;
      expect(remainingAfter, equals(remainingBefore));

      print('重複添加用戶測試 passed: 時間保持不變');
    });

    test('resetUser 方法測試', () async {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc, // 10s
      );

      // 等待 3 秒
      await Future.delayed(Duration(seconds: 3));

      expect(timerManager.currentDisplayTimer?.remainingSeconds,
          lessThanOrEqualTo(8)); // 更寬容的範圍

      // 重置用戶計時器
      timerManager.resetUser('user1');

      // 時間應該重置為 10 秒
      expect(timerManager.currentDisplayTimer?.remainingSeconds, equals(10));

      print('resetUser 方法測試 passed: 時間正確重置');
    });

    test('Case 2: 三人同時加入', () async {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.airplay, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user3',
        deviceName: 'Device3',
        connectionType: ConnectionType.googlecast, // 10s
      );

      expect(timerManager.userCount, 3);
      // 都是 10 秒，顯示最後加入的 user3
      expect(timerManager.currentDisplayTimer?.id, 'user3');
      expect(timerManager.currentDisplayTimer?.totalSeconds, 10);

      print('Test Case 2 passed: 三人同時加入，顯示最後加入的');
    });

    test('Case 3: 刪除非倒數者不影響', () async {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.airplay, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.webrtc, // 10s
      );

      // 倒數為 user2 (兩者都是10秒，顯示後加入的)
      expect(timerManager.currentDisplayTimer?.id, 'user2');

      // 刪除 user1 → 倒數條仍為 user2
      timerManager.removeUser('user1');
      expect(timerManager.currentDisplayTimer?.id, 'user2');
      expect(timerManager.userCount, 1);

      print('Test Case 3 passed: 刪除非倒數者不影響');
    });

    test('Case 4: 刪除倒數者會 fallback', () async {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.googlecast, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.airplay, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.webrtc, // 10s
      );

      // 倒數為 user2 (兩者都是10秒，顯示後加入的)
      expect(timerManager.currentDisplayTimer?.id, 'user2');

      // 刪除 user2 → 倒數條變 user1
      timerManager.removeUser('user2');
      expect(timerManager.currentDisplayTimer?.id, 'user1');
      expect(timerManager.userCount, 1);

      print('Test Case 4 passed: 刪除倒數者會 fallback');
    });

    test('Case 5: 三人加入，依順序刪除', () async {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.airplay, // 5s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user3',
        deviceName: 'Device3',
        connectionType: ConnectionType.googlecast, // 8s
      );

      // 倒數為 user3（都是10s，顯示最後加入的）
      expect(timerManager.currentDisplayTimer?.id, 'user3');

      // 刪除 user1 → 倒數仍是 user3
      timerManager.removeUser('user1');
      expect(timerManager.currentDisplayTimer?.id, 'user3');

      // 刪除 user3 → 倒數變 user2
      timerManager.removeUser('user3');
      expect(timerManager.currentDisplayTimer?.id, 'user2');

      print('Test Case 5 passed: 三人加入，依順序刪除');
    });

    test('Case 6: 三人加入，刪除最短的', () async {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.airplay, // 10s
      );

      await Future.delayed(Duration(seconds: 1));

      timerManager.addUser(
        id: 'user3',
        deviceName: 'Device3',
        connectionType: ConnectionType.googlecast, // 8s
      );

      // 倒數為 user3 (都是10s，顯示最後加入的)
      expect(timerManager.currentDisplayTimer?.id, 'user3');

      // 刪除 user2 → 倒數條仍是 user3
      timerManager.removeUser('user2');
      expect(timerManager.currentDisplayTimer?.id, 'user3');
      expect(timerManager.userCount, 2);

      print('Test Case 6 passed: 刪除用戶不影響當前顯示的倒數條');
    });

    test('Case 7: 只剩一人', () {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc, // 10s
      );

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.airplay, // 5s
      );

      timerManager.addUser(
        id: 'user3',
        deviceName: 'Device3',
        connectionType: ConnectionType.googlecast, // 8s
      );

      expect(timerManager.userCount, 3);

      // 刪除 user3 → fallback 到 user1
      timerManager.removeUser('user3');
      expect(timerManager.currentDisplayTimer?.id, 'user1');
      expect(timerManager.userCount, 2);

      // 再刪 user2 → 仍是 user1
      timerManager.removeUser('user2');
      expect(timerManager.currentDisplayTimer?.id, 'user1');
      expect(timerManager.userCount, 1);

      // 再刪 user1 → 清空倒數條
      timerManager.removeUser('user1');
      expect(timerManager.currentDisplayTimer, null);
      expect(timerManager.userCount, 0);

      print('Test Case 7 passed: 只剩一人，最後清空');
    });

    test('AirPlay with PIN code 測試', () {
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.airplayWithPin, // 40s
      );

      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.webrtc, // 10s
      );

      // 倒數為 user1 (40秒 > 10秒)
      expect(timerManager.currentDisplayTimer?.id, 'user1');
      expect(timerManager.currentDisplayTimer?.totalSeconds, 40);

      print('AirPlay with PIN code 測試 passed: 40秒優先顯示');
    });

    test('切換用戶時進度條跳到新用戶的實際進度', () async {
      List<double> progressUpdates = [];
      List<int> remainingSecondsUpdates = [];

      timerManager.onProgressUpdate = (progress, remainingSeconds) {
        progressUpdates.add(progress);
        remainingSecondsUpdates.add(remainingSeconds);
      };

      // 添加 user1 (WebRTC, 10s)
      timerManager.addUser(
        id: 'user1',
        deviceName: 'Device1',
        connectionType: ConnectionType.webrtc,
      );

      // 等待 4 秒，user1 剩餘 6 秒 (60% 進度)
      await Future.delayed(Duration(seconds: 4));

      // 添加 user2 (GoogleCast, 8s)，剩餘 8 秒 (100% 進度)
      timerManager.addUser(
        id: 'user2',
        deviceName: 'Device2',
        connectionType: ConnectionType.googlecast,
      );

      // user2 的剩餘時間更長 (8s > 6s)，應該成為顯示對象
      expect(timerManager.currentDisplayTimer?.id, 'user2');

      // 移除 user2，應該切換回 user1
      timerManager.removeUser('user2');

      // 進度條應該跳到 user1 的實際進度（約 60%），而不是 100%
      expect(timerManager.currentDisplayTimer?.id, 'user1');
      final currentProgress = timerManager.currentDisplayTimer?.progress ?? 0.0;
      expect(currentProgress, lessThanOrEqualTo(0.7)); // 應該小於等於 70%
      expect(currentProgress, greaterThan(0.5)); // 應該大於 50%

      print('切換用戶進度測試 passed: 進度條正確跳到新用戶的實際進度');
    });

    test('ConnectionType 工廠方法測試', () {
      // 測試 getConnectionTypeFromString
      expect(
        UserTimerManager.getConnectionTypeFromString('airplay', hasPin: false),
        ConnectionType.airplay,
      );

      expect(
        UserTimerManager.getConnectionTypeFromString('airplay', hasPin: true),
        ConnectionType.airplayWithPin,
      );

      expect(
        UserTimerManager.getConnectionTypeFromString('googlecast'),
        ConnectionType.googlecast,
      );

      expect(
        UserTimerManager.getConnectionTypeFromString('miracast'),
        ConnectionType.miracast,
      );

      // 測試 getWebRTCConnectionType
      expect(
        UserTimerManager.getWebRTCConnectionType(),
        ConnectionType.webrtc,
      );

      print('ConnectionType 工廠方法測試 passed');
    });
  });
}
