import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_cast_devices_menu.dart';
import 'package:display_flutter/screens/v3_participants_menu.dart';
import 'package:display_flutter/screens/v3_quick_connect_menu.dart';
import 'package:display_flutter/screens/v3_shortcuts_menu.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/v3_feature_set.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_settings_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'streaming_features_utils.dart';

/// Streaming 功能列 - 整合版本
///
/// 當 streaming 進行時顯示，整合 V3FeatureSet 與 ExpandableWidget 的功能
class StreamingFeaturesContainer extends StatefulWidget {
  const StreamingFeaturesContainer({super.key});

  @override
  State<StreamingFeaturesContainer> createState() =>
      _StreamingFeaturesContainerState();
}

class _StreamingFeaturesContainerState extends State<StreamingFeaturesContainer>
    with TickerProviderStateMixin {
  /// 是否展開
  bool _isExpanded = false;

  /// 當前垂直位置（top）
  double? _currentY;

  /// 是否已初始化位置
  bool _isPositionInitialized = false;

  /// 動畫控制器
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  /// 對話框狀態
  bool _isModeratorOnScreen = false;
  bool _isCastDeviceOnScreen = false;
  bool _isShortcutOnScreen = false;
  bool _isQuickConnectOnScreen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 展開動畫：從 0.0 (縮小) 到 1.0 (展開)
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 切換展開/收合
  void _toggleExpanded() {
    setState(() {
      if (_isExpanded) {
        // 收合時：讓縮小模式的中心點對齊展開模式的中心點
        // 必須在 _isExpanded 改變之前計算展開的高度
        final expandedHeight = _calculateCurrentHeight();
        final collapsedHeight = StreamingFeaturesConstants.collapsedSize;

        // 計算展開模式的中心點
        final expandedCenterY = (_currentY ?? 0) + expandedHeight / 2;

        // 計算縮小模式應該的 top，讓其中心點對齊展開模式的中心點
        final newTopY = expandedCenterY - collapsedHeight / 2;

        // 檢查是否會超出螢幕底部或頂部
        final screenHeight = MediaQuery.of(context).size.height;
        final minY = StreamingFeaturesConstants.verticalSafeMargin;
        final maxY = screenHeight -
            collapsedHeight -
            StreamingFeaturesConstants.verticalSafeMargin;

        // 限制在安全範圍內
        _currentY = newTopY.clamp(minY, maxY);

        _isExpanded = false;
        _animationController.reverse();
      } else {
        // 展開時：讓中心點對齊
        final collapsedHeight = StreamingFeaturesConstants.collapsedSize;

        _isExpanded = true;
        final expandedHeight = _calculateCurrentHeight();

        // 計算縮小模式的中心點
        final collapsedCenterY = (_currentY ?? 0) + collapsedHeight / 2;

        // 計算展開模式應該的 top，讓其中心點對齊縮小模式的中心點
        final newTopY = collapsedCenterY - expandedHeight / 2;

        // 檢查是否會超出螢幕底部或頂部
        final screenHeight = MediaQuery.of(context).size.height;
        final minY = StreamingFeaturesConstants.verticalSafeMargin;
        final maxY = screenHeight -
            expandedHeight -
            StreamingFeaturesConstants.verticalSafeMargin;

        // 限制在安全範圍內
        _currentY = newTopY.clamp(minY, maxY);

        _animationController.forward();
      }
    });
  }

  /// 更新垂直位置
  void _updateVerticalPosition(double newY) {
    setState(() {
      final screenHeight = MediaQuery.of(context).size.height;
      // 使用當前實際高度
      final widgetHeight = _calculateCurrentHeight();
      _currentY = clampVerticalPosition(
        yPosition: newY,
        screenHeight: screenHeight,
        widgetHeight: widgetHeight,
      );
    });
  }

  /// 計算當前模式的實際高度
  double _calculateCurrentHeight() {
    if (!_isExpanded) {
      return StreamingFeaturesConstants.collapsedSize;
    }

    // 展開模式：根據實際顯示的按鈕數量計算（參考 V3FeatureSet 的計算方式）
    int buttonCount = 0;

    // 檢查 Moderator 是否顯示
    if (ChannelProvider.isModeratorMode &&
        HybridConnectionList.hybridSplitScreenCount.value > 0) {
      buttonCount++;
    }

    // 檢查 Cast Device 是否顯示
    final channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    if (channelProvider.isSenderMode) {
      buttonCount++;
    }

    // 固定顯示的按鈕：Shortcuts, QuickConnect, (Collapse+Move)
    buttonCount += 3;

    // 計算總高度：按鈕高度 × 數量 + 分隔線高度 × (數量-1)
    const buttonHeight = StreamingFeaturesConstants.expandedButtonHeight;
    const dividerHeight = StreamingFeaturesConstants.dividerHeight;

    return (buttonCount * buttonHeight) +
        ((buttonCount - 1) * dividerHeight) +
        20;
  }

  @override
  Widget build(BuildContext context) {
    // 響應式判斷
    if (isCompactMode(context)) {
      return const SizedBox.shrink();
    }

    // 初始化預設位置（螢幕下方）
    if (!_isPositionInitialized) {
      final screenHeight = MediaQuery.of(context).size.height;
      final widgetHeight = _calculateCurrentHeight();
      _currentY = screenHeight -
          widgetHeight -
          StreamingFeaturesConstants.verticalSafeMargin;
      _isPositionInitialized = true;
    }

    return Consumer2<ChannelProvider, MirrorStateProvider>(
      builder: (context, channelProvider, mirrorProvider, _) {
        // 計算展開寬度（需要考慮 badge 寬度）
        final bigTextScalar =
            MediaQuery.of(context).textScaler.scale(1.0) > 1.0;
        final textSizePadding = bigTextScalar ? 8.0 : 0.0;

        final connectionCount = HybridConnectionList().getConnectionCount();
        final remoteScreenConnectors =
            channelProvider.remoteScreenConnectors.length;
        final anyOverThreeDigits =
            remoteScreenConnectors >= 100 || connectionCount >= 100;

        var countPadding = textSizePadding;
        var expandedTotalWidth = 57.0 + textSizePadding;
        if (anyOverThreeDigits) {
          countPadding = textSizePadding + 10;
          expandedTotalWidth = 60.0 + countPadding + 3;
        }

        return AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            // 計算當前寬度（從縮小尺寸到展開寬度的插值）
            final currentWidth = StreamingFeaturesConstants.collapsedSize +
                (_expandAnimation.value *
                    (expandedTotalWidth -
                        StreamingFeaturesConstants.collapsedSize));

            return Positioned(
              left: StreamingFeaturesConstants.screenEdgePadding,
              top: _currentY!,
              child: SizedBox(
                width: currentWidth,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // 展開模式（永遠在底層）
                    if (_expandAnimation.value > 0.0)
                      Opacity(
                        opacity: _expandAnimation.value,
                        child: _buildExpandedMode(
                          channelProvider,
                          mirrorProvider,
                          countPadding,
                          expandedTotalWidth,
                        ),
                      ),
                    // 縮小模式（在頂層，動畫時淡出）
                    if (_expandAnimation.value < 1.0)
                      Opacity(
                        opacity: 1.0 - _expandAnimation.value,
                        child: _buildCollapsedMode(),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 縮小模式 UI
  Widget _buildCollapsedMode() {
    return V3Focus(
      label: S.of(context).v3_lbl_streaming_shortcut_expand,
      identifier: 'v3_qa_streaming_shortcut_collapsed',
      // 使用 InkWell 處理點擊，支援 focus 系統
      child: InkWell(
        // 點擊時切換展開/收合狀態
        onTap: _toggleExpanded,
        // 使用 Listener 處理拖拉
        child: Listener(
          // 監聽指標移動事件，更新垂直位置
          onPointerMove: (details) {
            _updateVerticalPosition((_currentY ?? 0) + details.delta.dy);
          },
          child: SizedBox(
            width: StreamingFeaturesConstants.collapsedSize,
            height: StreamingFeaturesConstants.collapsedSize,
            child: Center(
              // 使用 CustomPaint 繪製三個點圖示（帶陰影）
              child: CustomPaint(
                size: const Size(36, 36),
                painter: _ThreeDotsMenuPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 展開模式 UI（V3FeatureSet 風格）
  Widget _buildExpandedMode(
    ChannelProvider channelProvider,
    MirrorStateProvider mirrorProvider,
    double countPadding,
    double containerWidth,
  ) {
    // 判斷顯示條件（沿用 V3FeatureSet 邏輯）
    bool showModerator = false;
    bool showCastDevice = false;

    if (ChannelProvider.isModeratorMode) {
      showModerator = true;
      if (HybridConnectionList.hybridSplitScreenCount.value == 0) {
        showModerator = false;
      }
    }
    if (channelProvider.isSenderMode) {
      showCastDevice = true;
    }

    final connectionCount = HybridConnectionList().getConnectionCount();
    final remoteScreenConnectors =
        channelProvider.remoteScreenConnectors.length;
    final remoteScreenConnectionFull =
        channelProvider.remoteScreenConnectionFull;

    // 判斷第一個按鈕是誰（決定誰需要右上角圓角）
    bool moderatorIsFirst = showModerator;
    bool castDeviceIsFirst = !showModerator && showCastDevice;
    bool shortcutsIsFirst = !showModerator && !showCastDevice;

    // 計算有多少功能要顯示
    final features = <Widget>[];
    int index = 0;

    // 1. Moderator Mode
    if (showModerator) {
      if (index > 0) features.add(_buildDivider());
      features.add(_buildModeratorButton(
        connectionCount,
        countPadding,
        isFirstButton: moderatorIsFirst,
      ));
      index++;
    }

    // 2. Cast Device Mode
    if (showCastDevice) {
      if (index > 0) features.add(_buildDivider());
      features.add(_buildCastDeviceButton(
        remoteScreenConnectors,
        remoteScreenConnectionFull,
        countPadding,
        isFirstButton: castDeviceIsFirst,
      ));
      index++;
    }

    // 3. Shortcuts Menu
    if (index > 0) features.add(_buildDivider());
    features.add(_buildShortcutsButton(
      countPadding,
      isFirstButton: shortcutsIsFirst,
    ));
    index++;

    // 4. Quick Connect Menu
    if (index > 0) features.add(_buildDivider());
    features.add(_buildQuickConnectButton(countPadding));
    index++;

    // 5. 縮小按鈕
    if (index > 0) features.add(_buildDivider());
    features.add(_buildCollapseButton(countPadding));
    index++;

    // 6. 移動把手
    features.add(_buildMoveHandle(countPadding));

    final height = _calculateCurrentHeight();

    return SizedBox(
      width: containerWidth,
      height: height,
      child: Stack(
        children: [
          // 主背景（白色/淺色）
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Container(
              width: StreamingFeaturesConstants.expandedMainWidth,
              height: height,
              decoration: BoxDecoration(
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
                borderRadius: const BorderRadius.only(
                  topRight:
                      Radius.circular(StreamingFeaturesConstants.borderRadius),
                  bottomRight:
                      Radius.circular(StreamingFeaturesConstants.borderRadius),
                ),
              ),
            ),
          ),
          // 功能按鈕
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features,
          ),
        ],
      ),
    );
  }

  /// 分隔線
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(right: 18),
      child: Container(
        height: StreamingFeaturesConstants.dividerHeight,
        color: context.tokens.color.vsdslColorOutline,
      ),
    );
  }

  /// Moderator 按鈕（V3FeatureSet 風格）
  Widget _buildModeratorButton(
    int connectionCount,
    double countPadding, {
    required bool isFirstButton,
  }) {
    return SizedBox(
      height: StreamingFeaturesConstants.expandedButtonHeight,
      child: V3Focus(
        trimBorder: true,
        label: S.of(context).v3_lbl_open_feature_set_moderator,
        identifier: 'v3_qa_open_feature_set_moderator',
        borderRadius: isFirstButton
            ? const BorderRadius.only(
                topRight: Radius.circular(10),
              )
            : BorderRadius.zero,
        child: Stack(
          children: [
            if (_isModeratorOnScreen)
              Positioned(
                right: 18.0,
                child: Container(
                  width: 50,
                  height: StreamingFeaturesConstants.expandedButtonHeight,
                  decoration: BoxDecoration(
                    color: context.tokens.color.vsdslColorSurface300,
                    borderRadius: isFirstButton
                        ? const BorderRadius.only(
                            topRight: Radius.circular(
                                StreamingFeaturesConstants.borderRadius),
                          )
                        : null,
                  ),
                ),
              ),
            Positioned(
              top: 15,
              left: 3,
              right: 21.0 + countPadding,
              child: SizedBox(
                width: 27,
                height: 27,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/ic_streaming_moderator_off.svg',
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    trackEvent(
                      'click_connection_info',
                      EventCategory.session,
                      mode: 'webrtc',
                    );
                    Future.microtask(() => _showParticipantsMenuDialog());
                  },
                ),
              ),
            ),
            if (connectionCount > 0)
              Positioned(
                right: 0,
                top: StreamingFeaturesConstants.expandedButtonHeight / 2 - 15,
                child: CircleCountBadge(
                  count: connectionCount,
                  countPadding: countPadding,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Cast Device 按鈕
  Widget _buildCastDeviceButton(
    int remoteScreenConnectors,
    bool remoteScreenConnectionFull,
    double countPadding, {
    required bool isFirstButton,
  }) {
    return SizedBox(
      height: StreamingFeaturesConstants.expandedButtonHeight,
      child: V3Focus(
        label: S.of(context).v3_lbl_open_feature_set_cast_device,
        identifier: 'v3_qa_open_feature_set_cast_device',
        borderRadius: isFirstButton
            ? const BorderRadius.only(
                topRight: Radius.circular(10),
              )
            : BorderRadius.zero,
        child: Stack(
          children: [
            if (_isCastDeviceOnScreen)
              Positioned(
                right: 18.0,
                child: Container(
                  width: 50,
                  height: StreamingFeaturesConstants.expandedButtonHeight,
                  decoration: BoxDecoration(
                    color: context.tokens.color.vsdslColorSurface300,
                    borderRadius: isFirstButton
                        ? const BorderRadius.only(
                            topRight: Radius.circular(
                                StreamingFeaturesConstants.borderRadius),
                          )
                        : null,
                  ),
                ),
              ),
            if (remoteScreenConnectors > 0)
              Positioned(
                right: 0,
                top: StreamingFeaturesConstants.expandedButtonHeight / 2 - 15,
                child: CircleCountBadge(
                  countPadding: countPadding,
                  count: remoteScreenConnectors,
                  backgroundColor: remoteScreenConnectionFull
                      ? context.tokens.color.vsdslColorError
                      : const Color(0xFF5D80ED),
                ),
              ),
            Positioned(
              left: 3,
              right: 21.0 + countPadding,
              top: 12,
              child: SizedBox(
                width: 27,
                height: 27,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/ic_streaming_device_list_off.svg',
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Future.microtask(() => _showCastDeviceMenuDialog());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shortcuts 按鈕
  Widget _buildShortcutsButton(
    double countPadding, {
    required bool isFirstButton,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final lock = settingsProvider.isSettingsLock;
        return SizedBox(
          height: StreamingFeaturesConstants.expandedButtonHeight,
          child: V3Focus(
            label: lock
                ? S.of(context).v3_lbl_streaming_shortcut_menu_locked
                : S.of(context).v3_lbl_open_streaming_shortcut_menu,
            identifier: lock
                ? 'v3_qa_streaming_shortcut_menu_locked'
                : 'v3_qa_open_streaming_shortcut_menu',
            borderRadius: BorderRadius.only(
              topRight: isFirstButton ? const Radius.circular(10) : Radius.zero,
              bottomRight: const Radius.circular(10),
            ),
            child: Stack(
              children: [
                if (_isShortcutOnScreen)
                  Positioned(
                    right: 18.0,
                    child: Container(
                      width: 50,
                      height: StreamingFeaturesConstants.expandedButtonHeight,
                      decoration: BoxDecoration(
                        color: context.tokens.color.vsdslColorSurface300,
                        borderRadius: isFirstButton
                            ? const BorderRadius.only(
                                topRight: Radius.circular(
                                    StreamingFeaturesConstants.borderRadius),
                              )
                            : null,
                      ),
                    ),
                  ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 3, right: 21.0 + countPadding),
                  child: SizedBox(
                    width: 27,
                    height: 27,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        lock
                            ? 'assets/images/ic_streaming_shortcut_locked.svg'
                            : 'assets/images/ic_streaming_menu_cast_to_devices.svg',
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Future.microtask(
                            () => _showShortcutsMenuDialog(settingsProvider));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Quick Connect 按鈕
  Widget _buildQuickConnectButton(double countPadding) {
    return SizedBox(
      height: StreamingFeaturesConstants.expandedButtonHeight,
      child: V3Focus(
        label: S.of(context).v3_lbl_open_streaming_qrcode_menu,
        identifier: 'v3_qa_open_streaming_qrcode_menu',
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Stack(
          children: [
            if (_isQuickConnectOnScreen)
              Positioned(
                right: 18.0,
                child: Container(
                  width: 50,
                  height: StreamingFeaturesConstants.expandedButtonHeight,
                  decoration: BoxDecoration(
                    color: context.tokens.color.vsdslColorSurface300,
                  ),
                ),
              ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 3, right: 21.0 + countPadding),
              child: SizedBox(
                width: 27,
                height: 27,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/ic_streaming_menu_share_your_screen.svg',
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Future.microtask(() => _showQuickConnectMenuDialog());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 縮小按鈕
  Widget _buildCollapseButton(double countPadding) {
    return V3Focus(
      label: S.of(context).v3_lbl_streaming_shortcut_minimize,
      identifier: 'v3_qa_streaming_shortcut_minimize',
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child: Container(
        alignment: Alignment.center,
        height: StreamingFeaturesConstants.expandedButtonHeight / 2 + 8,
        padding: EdgeInsets.only(left: 3, right: 21.0 + countPadding, top: 8),
        child: SizedBox(
          width: 27,
          height: 27,
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/images/ic_streaming_menu_minimize.svg',
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Future.microtask(() => _toggleExpanded());
            },
          ),
        ),
      ),
    );
  }

  /// 移動把手
  Widget _buildMoveHandle(double countPadding) {
    return SizedBox(
      height: StreamingFeaturesConstants.expandedButtonHeight / 2,
      child: V3Focus(
        identifier: 'v3_qa_streaming_shortcut_move',
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            _updateVerticalPosition((_currentY ?? 0) + details.delta.dy);
          },
          excludeFromSemantics: true,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 3, right: 21.0 + countPadding),
            child: SizedBox(
              width: 27,
              height: 27,
              child: Center(
                child: SvgPicture.asset(
                  excludeFromSemantics: true,
                  'assets/images/ic_streaming_menu_drag.svg',
                  width: 16,
                  height: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // 對話框顯示方法（使用動態定位）
  // ═══════════════════════════════════════════════════════

  /// 顯示 Participants Menu（Moderator）
  void _showParticipantsMenuDialog() async {
    if (!mounted) return;
    setState(() {
      _isModeratorOnScreen = true;
    });

    // 計算對話框位置（垂直中心對齊展開模式的中心）
    final screenSize = MediaQuery.of(context).size;
    final widgetHeight = _calculateCurrentHeight();
    final widgetCenterY = (_currentY ?? 0) + widgetHeight / 2;
    final widgetRight = StreamingFeaturesConstants.expandedMainWidth;

    const dialogSize = Size(384, 442); // V3ParticipantsMenu 的固定尺寸

    final dialogPosition = calculateDialogPositionFromCenter(
      widgetCenterY: widgetCenterY,
      widgetRight: widgetRight,
      dialogSize: dialogSize,
      screenHeight: screenSize.height,
    );

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => FocusAwareBuilder(
        builder: (primaryFocusNode) => V3ParticipantsMenu(
          primaryFocusNode: primaryFocusNode,
          position: dialogPosition,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _isModeratorOnScreen = false;
      });
    });
  }

  /// 顯示 Cast Device Menu
  void _showCastDeviceMenuDialog() async {
    if (!mounted) return;
    setState(() {
      _isCastDeviceOnScreen = true;
    });

    trackEvent('click_cast_to_device_icon', EventCategory.setting);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => FocusAwareBuilder(
        builder: (primaryFocusNode) =>
            V3CastDevicesMenu(primaryFocusNode: primaryFocusNode),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _isCastDeviceOnScreen = false;
      });
    });
  }

  /// 顯示 Shortcuts Menu
  void _showShortcutsMenuDialog(SettingsProvider settingsProvider) async {
    bool isShortcutsMenuUnLocked = true;

    // 檢查密碼鎖
    if (settingsProvider.isSettingsLock) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const V3SettingsPasswordDialog(),
      ).then((value) {
        isShortcutsMenuUnLocked = value;
      });
    }

    if (!(isShortcutsMenuUnLocked && mounted)) return;

    setState(() {
      _isShortcutOnScreen = true;
    });

    // 計算對話框位置（垂直中心對齊展開模式的中心）
    final screenSize = MediaQuery.of(context).size;
    final widgetHeight = _calculateCurrentHeight();
    final widgetCenterY = (_currentY ?? 0) + widgetHeight / 2;
    final widgetRight = StreamingFeaturesConstants.expandedMainWidth;

    const dialogSize = Size(226, 358); // V3ShortcutsMenu 的固定尺寸

    final dialogPosition = calculateDialogPositionFromCenter(
      widgetCenterY: widgetCenterY,
      widgetRight: widgetRight,
      dialogSize: dialogSize,
      screenHeight: screenSize.height,
    );

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => FocusAwareBuilder(
        builder: (primaryFocusNode) => V3ShortcutsMenu(
          primaryFocusNode: primaryFocusNode,
          position: dialogPosition,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _isShortcutOnScreen = false;
      });
    });
  }

  /// 顯示 Quick Connect Menu
  void _showQuickConnectMenuDialog() async {
    if (!mounted) return;
    setState(() {
      _isQuickConnectOnScreen = true;
    });

    // Quick Connect 不需要動態定位，使用原本的方式
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => FocusAwareBuilder(
        builder: (primaryFocusNode) =>
            V3QuickConnectMenu(primaryFocusNode: primaryFocusNode),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _isQuickConnectOnScreen = false;
      });
    });
  }
}

/// 垂直居中對齊的 Dialog Wrapper
///
/// 讓 dialog 的垂直中心點對齊指定的 widgetCenterY
class _AlignedDialog extends StatefulWidget {
  final double widgetCenterY;
  final double screenHeight;
  final Widget child;

  const _AlignedDialog({
    required this.widgetCenterY,
    required this.screenHeight,
    required this.child,
  });

  @override
  State<_AlignedDialog> createState() => _AlignedDialogState();
}

class _AlignedDialogState extends State<_AlignedDialog> {
  final GlobalKey _childKey = GlobalKey();
  double? _dialogHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureDialogHeight();
    });
  }

  void _measureDialogHeight() {
    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _dialogHeight = renderBox.size.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果還沒測量到高度，先透明顯示以便測量
    if (_dialogHeight == null) {
      return Opacity(
        opacity: 0.0,
        child: KeyedSubtree(
          key: _childKey,
          child: widget.child,
        ),
      );
    }

    // 計算 dialog 的 top 位置，讓其中心對齊 widgetCenterY
    final idealTop = widget.widgetCenterY - _dialogHeight! / 2;

    // 限制在安全範圍內
    final minTop = StreamingFeaturesConstants.verticalSafeMargin;
    final maxTop = widget.screenHeight -
        _dialogHeight! -
        StreamingFeaturesConstants.verticalSafeMargin;
    final safeMaxTop = maxTop < minTop ? minTop : maxTop;
    final finalTop = idealTop.clamp(minTop, safeMaxTop);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: widget.screenHeight,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(top: finalTop),
        child: widget.child,
      ),
    );
  }
}

/// 自訂繪製三個點的選單圖示（帶陰影）
///
/// 由於 flutter_svg 對 SVG filter 的支援有限，改用 CustomPaint 手動繪製
/// 確保陰影效果能正確顯示在每個圓點下方
class _ThreeDotsMenuPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 陰影畫筆設定
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25) // 黑色 25% 透明度
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // 模糊半徑 2.0

    // 白色圓點畫筆設定
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const double radius = 3.33; // 圓點半徑
    final double centerX = size.width / 2; // 水平中心點

    // 三個點的垂直位置（Y 座標）
    final List<double> dotYPositions = [
      size.height * 0.25, // 頂部點 (10/40)
      size.height * 0.5, // 中間點 (20/40)
      size.height * 0.75, // 底部點 (30/40)
    ];

    // 逐一繪製每個點
    for (final y in dotYPositions) {
      // 先繪製陰影（向下偏移 1px）
      canvas.drawCircle(
        Offset(centerX, y + 1),
        radius,
        shadowPaint,
      );

      // 再繪製白色圓點（覆蓋在陰影上方）
      canvas.drawCircle(
        Offset(centerX, y),
        radius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
