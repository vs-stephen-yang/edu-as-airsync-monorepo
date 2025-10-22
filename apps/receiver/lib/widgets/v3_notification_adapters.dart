import 'dart:async';

import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/screens/v3_new_sharing_menu.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/v3_bluetooth_touchback_status_notification.dart';
import 'package:display_flutter/widgets/v3_extend_casting_time_menu.dart';
import 'package:display_flutter/widgets/v3_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// V3 通知適配器（Notification Adapters）
/// ═══════════════════════════════════════════════════════════════
///
/// 職責：橋接舊系統和新的通知中心系統
///
/// 工作原理：
///   舊系統觸發 → Adapter 監聽到 → 呼叫 Manager.addNotification()
///
/// 優點：
///   - 舊程式碼完全不需要修改
///   - 自動監聽舊的 ValueNotifier
///   - 自動轉換成新的通知顯示
///
/// 包含的適配器：
///   1. V3ExtendCastingTimeNotificationAdapter - 延長投屏時間通知
///   2. V3BluetoothStatusNotificationAdapter - 藍牙狀態通知
///   3. V3NewSharingNotificationAdapter - 新用戶加入通知
///
/// 使用方式：
///   Stack(
///     children: [
///       const V3NotificationAdapters(), // 所有適配器
///       const V3NotificationCenter(),   // 通知中心
///     ],
///   )
///

/// ═══════════════════════════════════════════════════════════════
/// 延長投屏時間通知 - 適配器
/// ═══════════════════════════════════════════════════════════════
///
/// 監聽對象：V3ExtendCastingTimeMenu.showReamingTimeAlert
/// 觸發位置：lib/model/connect_timer.dart:53
///
/// 工作流程：
///   投屏剩餘 5 分鐘
///        ↓
///   connect_timer.dart 設定
///   showReamingTimeAlert.value = true
///        ↓
///   Adapter 監聽到變化
///        ↓
///   呼叫 Manager.addNotification()
///        ↓
///   NotificationCenter 顯示通知
///
///  注意：這個組件不顯示任何 UI，只負責監聽和轉換
///
class V3ExtendCastingTimeNotificationAdapter extends StatefulWidget {
  const V3ExtendCastingTimeNotificationAdapter({super.key});

  @override
  State<V3ExtendCastingTimeNotificationAdapter> createState() =>
      _V3ExtendCastingTimeNotificationAdapterState();
}

class _V3ExtendCastingTimeNotificationAdapterState
    extends State<V3ExtendCastingTimeNotificationAdapter> {
  // 保存當前顯示的通知 ID，用於後續移除
  String? _currentNotificationId;

  @override
  void initState() {
    super.initState();
    // ═══════════════════════════════════════════════════════════
    // 開始監聽舊系統的 ValueNotifier
    // ═══════════════════════════════════════════════════════════
    V3ExtendCastingTimeMenu.showReamingTimeAlert.addListener(_onAlertChanged);
  }

  @override
  void dispose() {
    // ═══════════════════════════════════════════════════════════
    // 停止監聽，避免記憶體洩漏
    // ═══════════════════════════════════════════════════════════
    V3ExtendCastingTimeMenu.showReamingTimeAlert
        .removeListener(_onAlertChanged);

    // 清理：如果還有通知在顯示，移除它
    if (_currentNotificationId != null) {
      V3NotificationCenterManager.removeNotification(_currentNotificationId!);
    }
    super.dispose();
  }

  /// ─────────────────────────────────────────────────────────────
  /// 當舊系統的狀態變化時呼叫
  /// ─────────────────────────────────────────────────────────────
  ///
  /// 觸發時機：
  ///   - showReamingTimeAlert.value 從 false 變成 true
  ///   - showReamingTimeAlert.value 從 true 變成 false
  ///
  void _onAlertChanged() {
    // 讀取舊系統的值
    final shouldShow = V3ExtendCastingTimeMenu.showReamingTimeAlert.value;

    if (shouldShow) {
      // ═══════════════════════════════════════════════════════════
      // 需要顯示通知
      // ═══════════════════════════════════════════════════════════

      // 如果已經有通知在顯示，先移除舊的（避免重複）
      if (_currentNotificationId != null) {
        V3NotificationCenterManager.removeNotification(_currentNotificationId!);
      }

      // 新增通知到通知中心
      _currentNotificationId = V3NotificationCenterManager.addNotification(
        type: V3NotificationType.extendCasting,
        child: const V3ExtendCastingTimeMenu(),
      );
    } else {
      // ═══════════════════════════════════════════════════════════
      // 需要隱藏通知
      // ═══════════════════════════════════════════════════════════

      // 從通知中心移除通知
      if (_currentNotificationId != null) {
        V3NotificationCenterManager.removeNotification(_currentNotificationId!);
        _currentNotificationId = null; // 清空 ID
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //  適配器不渲染任何 UI，返回空組件
    return const SizedBox.shrink();
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 藍牙狀態通知 - 適配器
/// ═══════════════════════════════════════════════════════════════
///
/// 監聽對象：V3BluetoothStatusNotification.showStatusAlert
/// 觸發位置：lib/providers/mirror_state_provider.dart
///
/// 工作流程：
///   藍牙狀態變化（連接中/已連接/失敗等）
///        ↓
///   mirror_state_provider.dart 設定
///   showStatusAlert.value = BluetoothProgress(...)
///        ↓
///   Adapter 監聽到變化
///        ↓
///   呼叫 Manager.addNotification()
///        ↓
///   NotificationCenter 顯示通知
///
/// 特殊邏輯：
///   - percent > 0.0 → 顯示通知
///   - percent == 0.0 → 隱藏通知
///
///  注意：這個組件不顯示任何 UI，只負責監聽和轉換
///
class V3BluetoothStatusNotificationAdapter extends StatefulWidget {
  const V3BluetoothStatusNotificationAdapter({super.key});

  @override
  State<V3BluetoothStatusNotificationAdapter> createState() =>
      _V3BluetoothStatusNotificationAdapterState();
}

class _V3BluetoothStatusNotificationAdapterState
    extends State<V3BluetoothStatusNotificationAdapter> {
  // 保存當前顯示的通知 ID，用於後續移除
  String? _currentNotificationId;

  @override
  void initState() {
    super.initState();
    // ═══════════════════════════════════════════════════════════
    // 開始監聽舊系統的 ValueNotifier
    // ═══════════════════════════════════════════════════════════
    V3BluetoothStatusNotification.showStatusAlert.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    // ═══════════════════════════════════════════════════════════
    // 停止監聽，避免記憶體洩漏
    // ═══════════════════════════════════════════════════════════
    V3BluetoothStatusNotification.showStatusAlert
        .removeListener(_onStatusChanged);

    // 清理：如果還有通知在顯示，移除它
    if (_currentNotificationId != null) {
      V3NotificationCenterManager.removeNotification(_currentNotificationId!);
    }
    super.dispose();
  }

  /// ─────────────────────────────────────────────────────────────
  /// 當舊系統的狀態變化時呼叫
  /// ─────────────────────────────────────────────────────────────
  ///
  /// 觸發時機：
  ///   - 藍牙開始連接（percent 從 0 變成 0.1+）
  ///   - 藍牙連接進度更新（percent 持續變化）
  ///   - 藍牙連接完成或失敗（percent 變成 0）
  ///
  void _onStatusChanged() {
    // 讀取舊系統的藍牙進度值
    final progress = V3BluetoothStatusNotification.showStatusAlert.value;

    // 判斷是否需要顯示通知
    // percent > 0.0 表示有藍牙活動（連接中、配對中等）
    final shouldShow = progress.percent > 0.0;

    if (shouldShow) {
      // ═══════════════════════════════════════════════════════════
      // 需要顯示通知
      // ═══════════════════════════════════════════════════════════

      // 如果已經有通知在顯示，先移除舊的（避免重複）
      if (_currentNotificationId != null) {
        V3NotificationCenterManager.removeNotification(_currentNotificationId!);
      }

      // 新增通知到通知中心
      _currentNotificationId = V3NotificationCenterManager.addNotification(
        type: V3NotificationType.bluetooth,
        child: const V3BluetoothStatusNotification(),
      );
    } else {
      // ═══════════════════════════════════════════════════════════
      // 需要隱藏通知
      // ═══════════════════════════════════════════════════════════

      // 從通知中心移除通知
      if (_currentNotificationId != null) {
        V3NotificationCenterManager.removeNotification(_currentNotificationId!);
        _currentNotificationId = null; // 清空 ID
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //  適配器不渲染任何 UI，返回空組件
    return const SizedBox.shrink();
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 新用戶加入分享通知 - 適配器
/// ═══════════════════════════════════════════════════════════════
///
/// 監聽對象：ChannelProvider.showNewSharingNameList
/// 觸發位置：lib/providers/channel_provider.dart
///
/// 工作流程：
///   新用戶加入投屏
///        ↓
///   channel_provider.dart 設定
///   showNewSharingNameList.value = ["Tom", "Jerry", ...]
///        ↓
///   Adapter 監聽到變化
///        ↓
///   為每個用戶呼叫 Manager.addNotification()
///        ↓
///   NotificationCenter 顯示通知
///
/// 特殊邏輯：
///   - 支援多個用戶同時加入（每個用戶一個通知）
///   - 用戶離開時自動移除對應通知
///   - 60 秒後自動關閉（由 V3NewSharingMenuContent 處理）
///
/// 資料結構：
///   _notificationIds = {
///     "Tom": "abc-123",    // 用戶名 → 通知 ID
///     "Jerry": "def-456",
///   }
///
///  注意：這個組件不顯示任何 UI，只負責監聽和轉換
///
class V3NewSharingNotificationAdapter extends StatefulWidget {
  const V3NewSharingNotificationAdapter({super.key});

  @override
  State<V3NewSharingNotificationAdapter> createState() =>
      _V3NewSharingNotificationAdapterState();
}

class _V3NewSharingNotificationAdapterState
    extends State<V3NewSharingNotificationAdapter> {
  /// ═══════════════════════════════════════════════════════════
  /// 追蹤每個用戶的通知 ID
  /// ═══════════════════════════════════════════════════════════
  ///
  /// Key: 用戶名稱（例如："Tom"）
  /// Value: 通知的唯一 ID（例如："abc-123"）
  ///
  /// 用途：當用戶離開或通知關閉時，能快速找到對應的通知 ID 來移除
  ///
  final Map<String, String> _notificationIds = {};

  /// ═══════════════════════════════════════════════════════════
  /// 共享的超時 Timer（小螢幕模式專用）
  /// ═══════════════════════════════════════════════════════════
  ///
  /// 用途：在小螢幕模式下，雖然不顯示通知，但仍需要 3 秒後自動清理所有用戶
  /// 規則：有新用戶加入時，重新倒數 3 秒
  ///
  Timer? _sharedTimer;

  @override
  Widget build(BuildContext context) {
    // 取得 ChannelProvider（不監聽，避免不必要的重建）
    final channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);

    // ═══════════════════════════════════════════════════════════
    // 監聽用戶列表的變化
    // ═══════════════════════════════════════════════════════════
    return ValueListenableBuilder<List<String>>(
      valueListenable: channelProvider.showNewSharingNameList,
      builder: (_, names, __) {
        // 調試輸出：檢查是否有接收到新用戶
        log.fine('V3NewSharingNotificationAdapter: 收到用戶列表更新 = $names');

        // ═══════════════════════════════════════════════════════════
        // 重要：在小螢幕情況下不顯示通知
        // ═══════════════════════════════════════════════════════════
        // NewSharing 通知在 launcher, launcherFull, oneThirdFull
        // 的情況下不應該出現在 notification center
        final currentRatio = context.splitScreenRatio;
        final shouldSkip = currentRatio == SplitScreenRatio.launcher ||
            currentRatio == SplitScreenRatio.launcherFull ||
            currentRatio == SplitScreenRatio.oneThirdFull;

        if (shouldSkip) {
          log.fine(
              'V3NewSharingNotificationAdapter: 小螢幕模式 ($currentRatio)，跳過通知');

          // 在小螢幕情況下，需要清除所有已存在的通知
          // （例如：用戶從大螢幕切換到小螢幕時）
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_notificationIds.isNotEmpty) {
              log.fine(
                  'V3NewSharingNotificationAdapter: 清除 ${_notificationIds.length} 個已存在的通知');
              for (final notificationId in _notificationIds.values) {
                V3NotificationCenterManager.removeNotification(notificationId);
              }
              _notificationIds.clear();
            }

            // ═══════════════════════════════════════════════════════════
            // 小螢幕模式：啟動共享倒數計時（3 秒）
            // ═══════════════════════════════════════════════════════════
            if (names.isNotEmpty) {
              // 有新用戶時，重新倒數
              _sharedTimer?.cancel();
              log.fine(
                  'V3NewSharingNotificationAdapter: 小螢幕模式，啟動 3 秒倒數（用戶數：${names.length}）');

              _sharedTimer = Timer(const Duration(seconds: 3), () {
                log.fine('V3NewSharingNotificationAdapter: 小螢幕模式，倒數結束，清空用戶列表');
                // 清空所有用戶
                channelProvider.showNewSharingNameList.value = [];
              });
            } else {
              // 沒有用戶時，取消計時
              _sharedTimer?.cancel();
              _sharedTimer = null;
            }
          });

          return const SizedBox.shrink();
        }

        // ═══════════════════════════════════════════════════════════
        // 重要：使用 addPostFrameCallback 避免在 build 中修改狀態
        // ═══════════════════════════════════════════════════════════
        // 在當前 frame 的 build 完成後執行，避免 "setState during build" 錯誤
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ───────────────────────────────────────────────────────
          // 步驟 1：移除已經離開的用戶通知
          // ───────────────────────────────────────────────────────
          //
          // 找出已經不在列表中的用戶
          // 例如：原本 _notificationIds 有 ["Tom", "Jerry"]
          //       但 names 只剩 ["Tom"]
          //       則 namesToRemove = ["Jerry"]
          //
          final namesToRemove = _notificationIds.keys
              .where((name) => !names.contains(name))
              .toList();

          // 移除這些用戶的通知
          for (final name in namesToRemove) {
            final notificationId = _notificationIds[name];
            if (notificationId != null) {
              // 從通知中心移除
              V3NotificationCenterManager.removeNotification(notificationId);
              // 從追蹤 Map 中移除
              _notificationIds.remove(name);
            }
          }

          // ───────────────────────────────────────────────────────
          // 步驟 2：新增新加入的用戶通知
          // ───────────────────────────────────────────────────────
          //
          // 找出新出現的用戶
          // 例如：names = ["Tom", "Jerry", "Alice"]
          //       但 _notificationIds 只有 ["Tom", "Jerry"]
          //       則需要為 "Alice" 新增通知
          //
          for (final name in names) {
            // 如果這個用戶還沒有通知，為他建立一個
            if (!_notificationIds.containsKey(name)) {
              // 調試輸出：準備新增通知
              log.fine('V3NewSharingNotificationAdapter: 為用戶 "$name" 新增通知');

              final notificationId =
                  V3NotificationCenterManager.addNotification(
                type: V3NotificationType.newSharing,
                child: V3NewSharingMenuContent(
                  name: name,

                  // ═══════════════════════════════════════════════
                  // 當用戶點擊關閉按鈕時的回呼
                  // ═══════════════════════════════════════════════
                  onDismiss: () {
                    // 1. 直接從通知中心移除這個通知
                    final id = _notificationIds[name];
                    if (id != null) {
                      V3NotificationCenterManager.removeNotification(id);
                      _notificationIds.remove(name);
                    }

                    // 2. 從用戶列表中移除這個用戶（保持資料同步）
                    channelProvider.showNewSharingNameList.value.remove(name);
                    channelProvider.showNewSharingNameList.value =
                        List.from(channelProvider.showNewSharingNameList.value);
                  },

                  // ═══════════════════════════════════════════════
                  // 當 60 秒倒數結束時的回呼
                  // ═══════════════════════════════════════════════
                  onTimeout: () {
                    // 1. 直接從通知中心移除這個通知
                    final id = _notificationIds[name];
                    if (id != null) {
                      V3NotificationCenterManager.removeNotification(id);
                      _notificationIds.remove(name);
                    }

                    // 2. 從用戶列表中移除這個用戶（保持資料同步）
                    channelProvider.showNewSharingNameList.value.remove(name);
                    channelProvider.showNewSharingNameList.value =
                        List.from(channelProvider.showNewSharingNameList.value);
                  },
                ),
              );

              // 記錄這個用戶的通知 ID
              _notificationIds[name] = notificationId;
            }
          }
        });

        // 適配器不渲染任何 UI，返回空組件
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    // ═══════════════════════════════════════════════════════════
    // 清理所有通知
    // ═══════════════════════════════════════════════════════════
    //
    // 當這個 Widget 被銷毀時（例如：離開投屏頁面）
    // 移除所有還在顯示的新用戶通知
    //
    for (final notificationId in _notificationIds.values) {
      V3NotificationCenterManager.removeNotification(notificationId);
    }
    _notificationIds.clear();

    // 取消倒數計時
    _sharedTimer?.cancel();

    super.dispose();
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 統一的通知適配器容器
/// ═══════════════════════════════════════════════════════════════
///
/// 職責：包含並初始化所有適配器
///
/// 使用方式：
///   Stack(
///     children: [
///       // 你的內容...
///       const V3NotificationAdapters(), // ← 新增這個
///       const V3NotificationCenter(),   // ← 還需要這個
///     ],
///   )
///
/// 包含的適配器：
///   1. V3ExtendCastingTimeNotificationAdapter - 延長投屏時間
///   2. V3BluetoothStatusNotificationAdapter - 藍牙狀態
///   3. V3NewSharingNotificationAdapter - 新用戶加入
///
/// 擴展方式：
///   如果需要新增其他通知類型，按照以下步驟：
///   1. 建立新的 Adapter（參考上面的三個範例）
///   2. 在下面的 Stack 中加入新的 Adapter
///   3. 完成！舊程式碼不需要改
///
/// 注意事項：
///   - 這個組件不顯示任何 UI
///   - 必須配合 V3NotificationCenter 一起使用
///   - 不要重複新增，一個 Stack 中只需要一個
///
class V3NotificationAdapters extends StatelessWidget {
  const V3NotificationAdapters({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // ═══════════════════════════════════════════════════════
        // 適配器 1：延長投屏時間通知
        // ═══════════════════════════════════════════════════════
        // 監聽：V3ExtendCastingTimeMenu.showReamingTimeAlert
        // 觸發：投屏剩餘 5 分鐘時
        V3ExtendCastingTimeNotificationAdapter(),

        // ═══════════════════════════════════════════════════════
        // 適配器 2：藍牙狀態通知
        // ═══════════════════════════════════════════════════════
        // 監聽：V3BluetoothStatusNotification.showStatusAlert
        // 觸發：藍牙連接狀態變化時
        // V3BluetoothStatusNotificationAdapter(),

        // ═══════════════════════════════════════════════════════
        // 適配器 3：新用戶加入通知
        // ═══════════════════════════════════════════════════════
        // 監聽：ChannelProvider.showNewSharingNameList
        // 觸發：有新用戶加入投屏時
        V3NewSharingNotificationAdapter(),

        // ═══════════════════════════════════════════════════════
        // 新增其他通知適配器的位置
        // ═══════════════════════════════════════════════════════
        //
        //
        // ═══════════════════════════════════════════════════════
      ],
    );
  }
}
