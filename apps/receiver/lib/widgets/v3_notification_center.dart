/// 統一管理全螢幕模式下的通知顯示，支援多個通知同時堆疊顯示
///
/// ## 使用方法
///
/// ### 1. 在你的 Widget 樹中新增 V3NotificationCenter
/// ```dart
/// Stack(
///   children: [
///     // 你的主要內容
///     MyContent(),
///
///     // 新增通知中心（固定在右下角）
///     V3NotificationCenter(),
///   ],
/// )
/// ```
///
/// ### 2. 顯示通知
/// ```dart
/// // 方式1: 使用自訂 Widget
/// String notificationId = V3NotificationCenterManager.addNotification(
///   type: V3NotificationType.custom,
///   child: MyCustomNotificationWidget(),
/// );
///
/// // 方式2: 使用現有的通知元件
/// String id = V3NotificationCenterManager.addNotification(
///   type: V3NotificationType.bluetooth,
///   child: V3BluetoothStatusNotification(),
/// );
/// ```
///
/// ### 3. 移除通知
/// ```dart
/// // 透過 ID 移除
/// V3NotificationCenterManager.removeNotification(notificationId);
///
/// // 清空所有通知
/// V3NotificationCenterManager.clearAll();
/// ```
///
/// ### 4. 遷移現有元件範例
/// ```dart
/// // 舊的方式（直接顯示在 Stack 中）
/// if (showBluetoothStatus) V3BluetoothStatusNotification()
///
/// // 新的方式（透過 Manager 管理）
/// if (showBluetoothStatus) {
///   _bluetoothNotificationId = V3NotificationCenterManager.addNotification(
///     type: V3NotificationType.bluetooth,
///     child: V3BluetoothStatusNotification(),
///   );
/// }
///
/// // 移除時
/// if (_bluetoothNotificationId != null) {
///   V3NotificationCenterManager.removeNotification(_bluetoothNotificationId!);
/// }
/// ```
///
/// ## 特性
/// - 固定在右下角顯示
/// - 支援無限數量的通知堆疊
/// - 新通知從下方滑入並往上推舊通知
/// - 通知間距 12px
/// - 平滑的進入/淡入動畫（300ms）
/// - 先來的通知在上方，後來的在下方（貼近螢幕底部）
/// - 通知消失後自動重新佈局
library;

import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/v3_webrtc_view.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 通知類型列舉
enum V3NotificationType {
  /// 延長投屏時間通知
  extendCasting,

  /// 藍牙狀態通知
  bluetooth,

  /// 新用戶加入分享通知
  newSharing,

  /// 自訂通知
  custom,
}

/// 通知項資料模型
class V3NotificationItem {
  /// 唯一識別符
  final String id;

  /// 通知類型
  final V3NotificationType type;

  /// 通知內容 Widget
  final Widget child;

  /// 建立時間
  final DateTime createdAt;

  V3NotificationItem({
    required this.id,
    required this.type,
    required this.child,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is V3NotificationItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// ═══════════════════════════════════════════════════════════════
/// V3 通知中心管理器（全域單例）
/// ═══════════════════════════════════════════════════════════════
///
/// 職責：管理所有通知的資料（新增、刪除、查詢）
/// 使用方式：
///   - addNotification() → 新增通知
///   - removeNotification(id) → 刪除通知
///   - clearAll() → 清空所有通知
///
///  注意：這個類別只管理資料，不負責顯示 UI
///         UI 顯示由 V3NotificationCenter 負責
///
class V3NotificationCenterManager {
  // 私有建構函式，防止外部建立實例（單例模式）
  V3NotificationCenterManager._();

  // UUID 生成器，用於為每個通知生成唯一 ID
  static final Uuid _uuid = const Uuid();

  /// ─────────────────────────────────────────────────────────────
  /// 核心資料：通知列表
  /// ─────────────────────────────────────────────────────────────
  ///
  /// 儲存格式：List<V3NotificationItem>
  /// 列表順序：
  ///    - 陣列索引 0 = 第一個加入的通知（顯示在上方）
  ///    - 陣列索引 1 = 第二個加入的通知（顯示在中間）
  ///    - 陣列索引 2 = 第三個加入的通知（顯示在下方，貼近底部）
  ///
  /// 視覺效果：
  ///    notifications[0] → 顯示在最上面
  ///    notifications[1] → 顯示在中間
  ///    notifications[2] → 顯示在最下面（靠近螢幕底部）
  ///
  static final ValueNotifier<List<V3NotificationItem>> notifications =
      ValueNotifier<List<V3NotificationItem>>([]);

  /// ─────────────────────────────────────────────────────────────
  /// 新增通知到列表
  /// ─────────────────────────────────────────────────────────────
  ///
  /// 參數：
  ///   [type] 通知類型（extendCasting, bluetooth, newSharing, custom）
  ///   [child] 通知的 Widget 內容
  ///
  /// 返回：
  ///   String - 通知的唯一 ID，用於後續刪除通知
  ///
  /// 使用範例：
  ///   String id = V3NotificationCenterManager.addNotification(
  ///     type: V3NotificationType.bluetooth,
  ///     child: MyBluetoothWidget(),
  ///   );
  ///
  static String addNotification({
    required V3NotificationType type,
    required Widget child,
  }) {
    // 1. 生成唯一 ID（例如："abc-123-def-456"）
    final id = _uuid.v4();

    // 2. 建立通知物件
    final item = V3NotificationItem(
      id: id,
      type: type,
      child: child,
      createdAt: DateTime.now(),
    );

    // 3. 加入到列表末尾（新通知會顯示在下方）
    final updatedList = List<V3NotificationItem>.from(notifications.value)
      ..add(item);

    // 4. 更新 ValueNotifier，觸發 UI 重新渲染
    notifications.value = updatedList;

    // 調試輸出：確認通知已添加
    log.fine(
        'V3NotificationCenterManager: 已新增通知 (ID: $id, 類型: $type, 總數: ${updatedList.length})');

    // 5. 返回 ID，呼叫者可以用這個 ID 來刪除通知
    return id;
  }

  /// ─────────────────────────────────────────────────────────────
  /// 移除指定 ID 的通知
  /// ─────────────────────────────────────────────────────────────
  ///
  /// 參數：
  ///   [id] 通知的唯一 ID（由 addNotification 返回的 ID）
  ///
  /// 使用範例：
  ///   V3NotificationCenterManager.removeNotification("abc-123");
  ///
  static void removeNotification(String id) {
    // 過濾掉要刪除的通知，保留其他通知
    final updatedList =
        notifications.value.where((item) => item.id != id).toList();

    // 更新列表，觸發 UI 重新渲染
    notifications.value = updatedList;
  }

  /// ─────────────────────────────────────────────────────────────
  /// 清空所有通知
  /// ─────────────────────────────────────────────────────────────
  ///
  /// 使用範例：
  ///   V3NotificationCenterManager.clearAll();
  ///
  static void clearAll() {
    notifications.value = [];
  }
}

/// ═══════════════════════════════════════════════════════════════
/// V3 通知中心 Widget（UI 渲染元件）
/// ═══════════════════════════════════════════════════════════════
///
/// 職責：在螢幕右下角顯示所有通知
///
/// 視覺效果：
///   ┌────────┐ ← 第1個通知（最早的）
///   ├────────┤
///   │ 間距12px│
///   ├────────┤
///   ┌────────┐ ← 第2個通知
///   ├────────┤
///   │ 間距12px│
///   ├────────┤
///   ┌────────┐ ← 第3個通知（最新的，貼近底部）
///   └────────┘
///      54px    ← 距離底邊
///
/// 使用方式：
///   Stack(
///     children: [
///       // 你的內容...
///       const V3NotificationCenter(), // 新增在這裡
///     ],
///   )
///
///  自訂參數：
///   V3NotificationCenter(
///     right: 100,   // 改變右邊距
///     bottom: 100,  // 改變底邊距
///     spacing: 16,  // 改變通知間距
///   )
///
class V3NotificationCenter extends StatelessWidget {
  /// 距離螢幕右邊的距離（預設 54px）
  final double? right;

  /// 距離螢幕底部的距離（預設 54px）
  final double? bottom;

  /// 通知之間的垂直間距（預設 12px）
  final double spacing;

  const V3NotificationCenter({
    super.key,
    this.right,
    this.bottom,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // 監聽 Manager 的通知列表變化
    return ValueListenableBuilder<List<V3NotificationItem>>(
      valueListenable: V3NotificationCenterManager.notifications,
      builder: (context, items, _) {
        // 調試輸出：確認 UI 收到通知列表更新
        log.fine('V3NotificationCenter: 收到通知列表更新，數量 = ${items.length}');

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        // ═══════════════════════════════════════════════════════════
        // 根據螢幕尺寸決定佈局方式
        // ═══════════════════════════════════════════════════════════
        // 在小螢幕（launcher, launcherFull, oneThirdFull）時，
        // 需要避開頂部的 namelabel（用戶名稱標籤）
        final currentRatio = context.splitScreenRatio;
        final isSmallScreen = currentRatio.widthFraction <
            SplitScreenRatio.oneThirdFull.widthFraction;

        // 小螢幕：從 namelabel 下方開始顯示通知
        if (isSmallScreen) {
          // 動態獲取 namelabel 的高度
          final nameLabelHeight =
              V3WebrtcView.nameLabelKey.currentContext?.size?.height;
          const spacing = 5.0; // 與 namelabel 的間距
          const defaultTop = 25.0; // 預設值（約 18pt namelabel + 7pt 間距）

          final topPosition =
              nameLabelHeight != null ? nameLabelHeight + spacing : defaultTop;

          return Positioned(
            top: topPosition,
            // 從 namelabel 下方開始
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              alignment: Alignment.topCenter, // 所有通知對齊到頂部中央
              children: _buildNotificationList(items),
            ),
          );
        }

        // 大螢幕：使用固定位置
        return Positioned(
          right: right ?? 54,
          bottom: bottom ?? 54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _buildNotificationList(items),
          ),
        );
      },
    );
  }

  /// ─────────────────────────────────────────────────────────────
  /// 建立通知列表（內部方法）
  /// ─────────────────────────────────────────────────────────────
  ///
  /// 渲染邏輯：
  ///   items[0] → Widget → 間距 12px
  ///   items[1] → Widget → 間距 12px
  ///   items[2] → Widget → （最後一個不加間距）
  ///
  /// 視覺效果：保持陣列順序，先來的在上方
  ///
  List<Widget> _buildNotificationList(List<V3NotificationItem> items) {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      // 為每個通知新增動畫包裝器
      widgets.add(
        _AnimatedNotificationItem(
          key: ValueKey(items[i].id), // 使用 ID 作為 key，最佳化效能
          item: items[i],
        ),
      );

      // 在通知之間新增間距（最後一個通知不需要間距）
      if (i < items.length - 1) {
        widgets.add(SizedBox(height: spacing));
      }
    }

    return widgets;
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 帶動畫的通知項（內部元件）
/// ═══════════════════════════════════════════════════════════════
///
/// 職責：為通知新增進入動畫效果
///
/// 動畫效果：
///   1. 滑入：從下方 30% 的位置滑入到原位
///   2. 淡入：透明度從 0 漸變到 1
///   3. 時長：300 毫秒
///
/// 動畫軌跡：
///   開始位置：Offset(0, 0.3) + opacity 0.0
///        ↓
///   結束位置：Offset(0, 0) + opacity 1.0
///
class _AnimatedNotificationItem extends StatefulWidget {
  final V3NotificationItem item;

  const _AnimatedNotificationItem({
    super.key,
    required this.item,
  });

  @override
  State<_AnimatedNotificationItem> createState() =>
      _AnimatedNotificationItemState();
}

class _AnimatedNotificationItemState extends State<_AnimatedNotificationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ─────────────────────────────────────────────────────────────
    // 建立動畫控制器
    // ─────────────────────────────────────────────────────────────
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // 動畫時長 300ms
      vsync: this,
    );

    // ─────────────────────────────────────────────────────────────
    // 滑入動畫：從下往上滑入
    // ─────────────────────────────────────────────────────────────
    // Offset(0, 0.3) → 起始位置（向下偏移 30%）
    // Offset(0, 0)   → 結束位置（原始位置）
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // 起點：向下偏移
      end: Offset.zero, // 終點：原位
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // 緩出曲線，結束時減速
    ));

    // ─────────────────────────────────────────────────────────────
    // 淡入動畫：透明度漸變
    // ─────────────────────────────────────────────────────────────
    // 0.0 → 完全透明
    // 1.0 → 完全不透明
    _fadeAnimation = Tween<double>(
      begin: 0.0, // 起點：透明
      end: 1.0, // 終點：不透明
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // 緩入曲線，開始時加速
    ));

    // 立即啟動動畫
    _controller.forward();
  }

  @override
  void dispose() {
    // 清理動畫控制器，避免記憶體洩漏
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 組合兩個動畫：滑入 + 淡入
    return SlideTransition(
      position: _slideAnimation, // 滑動動畫
      child: FadeTransition(
        opacity: _fadeAnimation, // 淡入動畫
        child: widget.item.child, // 實際的通知內容
      ),
    );
  }
}
