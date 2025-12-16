import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:display_flutter/utility/navigation_service_util.dart';
import 'package:display_flutter/widgets/v3_bluetooth_touchback_status_notification.dart';
import 'package:display_flutter/widgets/v3_casting_view_focus_traversal_policy.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_mini_notify_icon.dart';
import 'package:display_flutter/widgets/v3_notification_adapters.dart';
import 'package:display_flutter/widgets/v3_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

import 'streaming_item.dart';
import 'streaming_view_config.dart';

class V3StreamingView extends StatefulWidget {
  final StreamingViewConfig config;

  const V3StreamingView({super.key, required this.config});

  @override
  State<V3StreamingView> createState() => _V3StreamingViewState();
}

class _V3StreamingViewState extends State<V3StreamingView> {
  int _pageIndex = 0;
  int _dotCount = 3;

  @override
  void dispose() {
    // 退出 streaming 狀態時，清空所有通知
    V3NotificationCenterManager.clearAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FocusTraversalGroup(
      policy: CastingViewFocusTraversalPolicy(),
      child: Stack(
        children: [
          ConstrainedBox(constraints: const BoxConstraints.expand()),
          _buildStreamStack(size),
          BottomOverlayMenus(),

          // PageHeaderFooter 與 MiniNotifyIcon
          //    - 小螢幕時：MiniNotifyIcon 顯示在 VerticalPageIndicator 上方
          //    - 大螢幕時：只顯示 VerticalPageIndicator
          //
          _buildPageHeaderFooterWithMiniIcon(),
          // ═══════════════════════════════════════════════════════
          // 新的通知中心系統
          // ═══════════════════════════════════════════════════════
          //
          // V3NotificationAdapters（適配器層）
          //    - 職責：監聽舊系統的通知觸發
          //    - 不顯示 UI，只做資料轉換
          //    - 自動呼叫 Manager.addNotification()
          //
          const V3NotificationAdapters(),

          // V3NotificationCenter（顯示層）
          //    - 會根據 VerticalPageIndicator 調整位置
          //
          _buildNotificationCenter(),

        ],
      ),
    );
  }

  Widget _buildStreamStack(Size size) {
    return ValueListenableBuilder<int>(
      valueListenable: HybridConnectionList.hybridSplitScreenCount,
      builder: (ctx, count, _) {
        final adjustedCount = widget.config.adjustSplitCount(count);
        _dotCount = (count ~/ widget.config.dotCount) +
            ((count % widget.config.dotCount) > 0 ? 1 : 0);
        if (_pageIndex >= _dotCount && _dotCount != 0) {
          _pageIndex -= 1;
        }
        if (count > 0) navService.dismissRegisteredDialogs();
        if (count == 0 && navService.canPop()) navService.goBack();

        Provider.of<ChannelProvider>(ctx, listen: false)
            .refreshOnlyWhenCastingStatus();

        return Stack(
          children: [
            ConstrainedBox(constraints: BoxConstraints.expand()),
            ...List.generate(
              adjustedCount,
              (idx) => ValueListenableBuilder<int?>(
                valueListenable: HybridConnectionList().enlargedScreenIndex,
                builder: (_, enlarged, __) {
                  return StreamingItem(
                    index: idx,
                    count: adjustedCount,
                    enlarged: enlarged,
                    screenSize: size,
                    pageIndex: _pageIndex,
                    calculatePosition: () => widget.config.positionCalculator(
                      index: idx,
                      count: adjustedCount,
                      enlarged: enlarged,
                      screenSize: size,
                      pageIndex: _pageIndex,
                    ),
                  );
                },
              ),
            ),
            if (_shouldShowHeader(count))
              Positioned(child: const V3HeaderBar(isWaitForStream: true)),
          ],
        );
      },
    );
  }

  bool _shouldShowHeader(int count) {
    return count == 1 &&
        HybridConnectionList().isRTCConnector(0) &&
        (HybridConnectionList().getConnection(0) as RTCConnector)
                .presentationState ==
            PresentationState.waitForStream;
  }

  /// 建立通知中心（調整位置避開 VerticalPageIndicator）
  Widget _buildNotificationCenter() {
    return ValueListenableBuilder<bool>(
      valueListenable: V3Home.isShowHeaderFooterBar,
      builder: (_, show, __) => ValueListenableBuilder<int>(
        valueListenable: HybridConnectionList.hybridSplitScreenCount,
        builder: (ctx, count, _) {
          // 檢查是否有 PageHeaderFooter
          final pageHeaderFooter = !show
              ? widget.config.buildPageHeaderFooter
                  ?.call(_pageIndex, _dotCount, _nextPage)
              : null;

          // 計算 right 位置：如果有 VerticalPageIndicator，需要水平避開它
          double? right;
          if (pageHeaderFooter is Positioned &&
              pageHeaderFooter.right != null) {
            const indicatorWidth = 36.0; // VerticalPageIndicator 寬度
            right = pageHeaderFooter.right! + indicatorWidth + 8; // 加 8pt 間距
          }

          return V3NotificationCenter(right: right);
        },
      ),
    );
  }

  /// 建立 PageHeaderFooter 與 MiniNotifyIcon（放在同一個 Column）
  Widget _buildPageHeaderFooterWithMiniIcon() {
    return ValueListenableBuilder<bool>(
      valueListenable: V3Home.isShowHeaderFooterBar,
      builder: (_, show, __) {
        if (show) return const SizedBox.shrink();

        return ValueListenableBuilder<int>(
          valueListenable: HybridConnectionList.hybridSplitScreenCount,
          builder: (ctx, count, _) {
            final pageHeaderFooter = widget.config.buildPageHeaderFooter
                ?.call(_pageIndex, _dotCount, _nextPage);

            if (pageHeaderFooter is! Positioned) {
              return const SizedBox.shrink();
            }

            return Positioned(
              left: pageHeaderFooter.left,
              right: pageHeaderFooter.right,
              bottom: pageHeaderFooter.bottom ?? 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: pageHeaderFooter.left != null
                    ? CrossAxisAlignment.start // 左對齊（ExpandableWidget）
                    : CrossAxisAlignment.end, // 右對齊（VerticalPageIndicator）
                children: [
                  // MiniNotifyIcon 在上方（小螢幕時顯示）
                  const V3MiniNotifyIcon(),
                  const SizedBox(height: 8), // 間距
                  // PageHeaderFooter 在下方
                  pageHeaderFooter.child,
                ],
              ),
            );
          },
        );
      },
    );
  }
  void _nextPage() {
    if (!mounted) return;
    setState(() {
      _pageIndex = (_pageIndex + 1) % _dotCount;
    });
  }
}

class BottomOverlayMenus extends StatelessWidget {

  const BottomOverlayMenus({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.splitScreenRatio.widthFraction <
        SplitScreenRatio.oneThirdFull.widthFraction) {
      return Positioned.fill(
        child: Stack(
          children: [
            V3BluetoothStatusNotification(),
          ],
        ),
      );
    }

    return Positioned(
      bottom: 54,
      right: 53,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          V3BluetoothStatusNotification(),
        ],
      ),
    );
  }
}