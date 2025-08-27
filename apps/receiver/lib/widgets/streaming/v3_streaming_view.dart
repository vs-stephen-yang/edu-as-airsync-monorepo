import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:display_flutter/screens/v3_new_sharing_menu.dart';
import 'package:display_flutter/utility/navigation_service_util.dart';
import 'package:display_flutter/widgets/v3_bluetooth_touchback_status_notification.dart';
import 'package:display_flutter/widgets/v3_casting_view_focus_traversal_policy.dart';
import 'package:display_flutter/widgets/v3_extend_casting_time_menu.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
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
  bool _isNewSharingOnScreen = false;
  int _pageIndex = 0;
  int _dotCount = 3;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FocusTraversalGroup(
      policy: CastingViewFocusTraversalPolicy(),
      child: Stack(
        children: [
          _buildStreamStack(size),
          _buildHeaderFooter(),
          _buildNewSharingListener(),
          BottomOverlayMenus(isLifted: _isNewSharingOnScreen),
        ],
      ),
    );
  }

  Widget _buildStreamStack(Size size) {
    return ValueListenableBuilder<int>(
      valueListenable: HybridConnectionList.hybridSplitScreenCount,
      builder: (ctx, count, _) {
        final adjustedCount = widget.config.adjustSplitCount(count);
        _dotCount = (count ~/ 3) + ((count % 3) > 0 ? 1 : 0);
        if (_pageIndex >= _dotCount && _dotCount != 0) {
          _pageIndex -= 1;
        }
        if (count > 0) navService.dismissRegisteredDialogs();
        if (count == 0 && navService.canPop()) navService.goBack();

        Provider.of<ChannelProvider>(ctx, listen: false)
            .refreshOnlyWhenCastingStatus();

        return Stack(
          children: [
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
              const V3HeaderBar(isWaitForStream: true),
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

  Widget _buildHeaderFooter() {
    return ValueListenableBuilder<bool>(
      valueListenable: V3Home.isShowHeaderFooterBar,
      builder: (_, show, __) {
        return show
            ? const SizedBox.shrink()
            : ValueListenableBuilder<int>(
                valueListenable: HybridConnectionList.hybridSplitScreenCount,
                builder: (ctx, count, _) {
                  return (widget.config.buildPageHeaderFooter
                          ?.call(_pageIndex, _dotCount, _nextPage) ??
                      const SizedBox.shrink());
                },
              );
      },
    );
  }

  Widget _buildNewSharingListener() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: Provider.of<ChannelProvider>(context, listen: false)
          .showNewSharingNameList,
      builder: (_, names, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (names.isNotEmpty &&
              HybridConnectionList.hybridSplitScreenCount.value > 0 &&
              !_isNewSharingOnScreen) {
            _showNewSharingMessageDialog(names);
          }
        });
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _showNewSharingMessageDialog(List<String> names) async {
    final name = names.first;
    setState(() => _isNewSharingOnScreen = true);
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => V3NewSharingMenu(name: name),
    );
    if (!mounted) return;
    final prov = Provider.of<ChannelProvider>(context, listen: false);
    prov.showNewSharingNameList.value.remove(name);
    prov.showNewSharingNameList.value =
        List.from(prov.showNewSharingNameList.value);
    setState(() => _isNewSharingOnScreen = false);
  }

  void _nextPage() {
    setState(() {
      _pageIndex = (_pageIndex + 1) % _dotCount;
    });
  }
}

class BottomOverlayMenus extends StatelessWidget {
  final bool isLifted;

  const BottomOverlayMenus({super.key, required this.isLifted});

  @override
  Widget build(BuildContext context) {
    final inMin = context.splitScreenRatio == SplitScreenRatio.launcher;
    return Positioned(
      bottom: inMin
          ? 0
          : isLifted
              ? 164
              : 54,
      right: inMin ? 0 : 53,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          V3ExtendCastingTimeMenu(),
          V3BluetoothStatusNotification(),
        ],
      ),
    );
  }
}
