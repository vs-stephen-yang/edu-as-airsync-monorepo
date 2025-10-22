import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// V3 迷你通知圖示（Mini Notify Icon）
/// ═══════════════════════════════════════════════════════════════
///
/// 職責：在小螢幕情況下顯示新用戶加入的小圖示
///
/// 顯示條件：
///   - 螢幕尺寸為 launcher, launcherFull, oneThirdFull
///   - 有新用戶加入（showNewSharingNameList 不為空）
///
/// 位置邏輯：
///   - 與 VerticalPageIndicator 放在同一個 Column 中
///   - 顯示在 VerticalPageIndicator 上方，間距 8pt
///   - 大小：36x36（與 VerticalPageIndicator 寬度相同）
///
/// 使用方式：
///   Column(
///     children: [
///       V3MiniNotifyIcon(), // 在上方
///       SizedBox(height: 8),
///       VerticalPageIndicator(...), // 在下方
///     ],
///   )
///
class V3MiniNotifyIcon extends StatelessWidget {
  const V3MiniNotifyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // 檢查螢幕尺寸：只在小螢幕時顯示
    final currentRatio = context.splitScreenRatio;
    final isSmallScreen = currentRatio == SplitScreenRatio.launcher ||
        currentRatio == SplitScreenRatio.launcherFull ||
        currentRatio == SplitScreenRatio.oneThirdFull;

    if (!isSmallScreen) return const SizedBox.shrink();

    // 監聽新用戶列表
    final channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);

    return ValueListenableBuilder<List<String>>(
      valueListenable: channelProvider.showNewSharingNameList,
      builder: (_, names, __) {
        if (names.isEmpty) return const SizedBox.shrink();

        // 直接返回內容（不需要 Positioned，由父 Column 處理位置）
        return const _MiniNotifyIconContent();
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 迷你通知圖示內容（內部組件）
/// ═══════════════════════════════════════════════════════════════
///
/// 顯示一個小圖示，標示有新用戶加入
///
class _MiniNotifyIconContent extends StatelessWidget {
  /// 新用戶數量

  const _MiniNotifyIconContent();

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/images/ic_mini_notify.svg',
        width: size,
        height: size,
      ),
    );
  }
}
