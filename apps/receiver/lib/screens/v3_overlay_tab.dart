import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:android_window/android_window.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/utility/misc_util.dart';
import 'package:display_flutter/widgets/v3_dialog_action_buttons.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class V3OverlayTab extends StatefulWidget {
  const V3OverlayTab({super.key});

  @override
  State<StatefulWidget> createState() => _V3OverlayTabState();
}

class _V3OverlayTabState extends State<V3OverlayTab> {
  bool _isExpandedMode = false;
  String _deviceName = '';
  String _displayCode = '';
  String _otp = '';

  OverlayType overlayType = OverlayType.tab;

  @override
  void initState() {
    super.initState();
    setExpandedMode();
    _setUpAndroidWindow();
  }

  Future<void> setExpandedMode() async {
    var deviceType = await DeviceInfoVs.deviceType;
    bool isCDE = deviceType?.toString().startsWith('CDE') ?? false;
    bool isLED = deviceType?.toString().startsWith('dvLED') ?? false;
    if (isCDE || isLED) {
      if (!mounted) return;
      setState(() {
        _isExpandedMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      fontSize: 12,
      color: context.tokens.color.vsdslColorOnSurfaceInverse,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );

    /// todo: improve relayout mechanism
    ///  currently will show overflow markings (yellow/back strips) in debug mode
    ///  however release mode won't.

    switch (overlayType) {
      case OverlayType.retryDialog:
        final screenSize = PlatformDispatcher.instance.displays.first.size /
            PlatformDispatcher.instance.displays.first.devicePixelRatio;
        return RetryDialog(
            screenSize: screenSize, onRetry: onRetry, onStop: onStop);
      case OverlayType.tab:
        return AndroidWindow(
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  color: context.tokens.color.vsdslColorOpacityNeutralXl,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                  child: _isExpandedMode
                      ? Semantics(
                          label: S.of(context).v3_lbl_overlay_bring_app_to_top,
                          identifier: 'v3_qa_overlay_bring_app_to_top',
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              AndroidWindow.launchApp();
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_overlay_tab_dots.svg',
                                  width: 7,
                                  height: 14,
                                  colorFilter: ColorFilter.mode(
                                    context
                                        .tokens.color.vsdslColorNeutralInverse,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Semantics(
                                  label: S
                                      .of(context)
                                      .v3_lbl_overlay_menu_minimize,
                                  identifier: 'v3_qa_overlay_menu_minimize',
                                  button: true,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (!mounted) return;
                                      setState(() {
                                        _isExpandedMode = false;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/ic_overlay_tab_opened.svg',
                                      width: 26,
                                      height: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'assets/images/ic_screen.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // Trailing is device name, should not use - to confuse user
                                Text(
                                  _deviceName,
                                  style: textStyle,
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'assets/images/ic_qrcode.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // Trailing is display code, should not use - to confuse user
                                Text(
                                  getDisplayCodeVisualIdentity(_displayCode),
                                  style: textStyle,
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'assets/images/ic_otp.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // Trailing is otp code, should not use - to confuse user
                                Text(
                                  _otp,
                                  style: textStyle,
                                ),
                                const SizedBox(width: 13),
                                SvgPicture.asset(
                                  'assets/images/ic_overlay_tab_dots.svg',
                                  width: 7,
                                  height: 14,
                                  colorFilter: ColorFilter.mode(
                                    context
                                        .tokens.color.vsdslColorNeutralInverse,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Semantics(
                          label: S.of(context).v3_lbl_overlay_menu_expand,
                          identifier: 'v3_qa_overlay_menu_expand',
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (!mounted) return;
                              setState(() {
                                _isExpandedMode = true;
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/images/ic_overlay_tab_closed.svg',
                              width: 26,
                              height: 26,
                            ),
                          ),
                        ),
                ),
                StealthFpsKeeper(fps: 10),
              ],
            ),
          ),
        );
      case OverlayType.fpsKeeper:
        return AndroidWindow(
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            child: StealthFpsKeeper(fps: 10),
          ),
        );
    }
  }

  void onStop() {
    if (!mounted) return;
    setState(() {
      overlayType = OverlayType.tab;
      AndroidWindow.post(OverlayTabHandler.actionStopPublisher);
      AndroidWindow.setVisibility(false);
    });
  }

  void onRetry() {
    if (!mounted) return;
    setState(() {
      overlayType = OverlayType.tab;
      AndroidWindow.launchApp();
      AndroidWindow.post(OverlayTabHandler.actionRecreatePublisher);
      AndroidWindow.setVisibility(false);
    });
  }

  _setUpAndroidWindow() {
    var self = this;
    AndroidWindow.setHandler((String name, Object? data) async {
      switch (name) {
        case OverlayTabHandler.nameOverlayTabCheck:
          await AndroidWindow.post(OverlayTabHandler.nameOverlayTabReady);
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameInitValue:
          if (data is Map<Object?, Object?>) {
            if (!mounted) return OverlayTabHandler.resultEmptyString;
            setState(() {
              var info = Map<String, String>.from(data);
              _deviceName = info[OverlayTabHandler.keyDeviceName] ?? '';
              _displayCode = info[OverlayTabHandler.keyDisplayCode] ?? '';
              _otp = info[OverlayTabHandler.keyOtpCode] ?? '';
            });
          } else {
            log('set init value with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameSetVisibility:
          if (data is Map<Object?, Object?>) {
            if (!mounted) return OverlayTabHandler.resultEmptyString;
            setState(() {
              var info = Map<String, String>.from(data);
              AndroidWindow.setVisibility(
                  (info[OverlayTabHandler.keyVisibility] ??
                          OverlayTabHandler.valueInvisible) ==
                      OverlayTabHandler.valueVisible);
            });
          } else {
            log('set visibility with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameGetVisibility:
          var visible = await AndroidWindow.getVisibility()
              ? OverlayTabHandler.valueVisible
              : OverlayTabHandler.valueInvisible;
          return {OverlayTabHandler.keyVisibility: visible};

        case OverlayTabHandler.nameSetMainInfo:
          if (data is Map<Object?, Object?>) {
            if (!mounted) return OverlayTabHandler.resultEmptyString;
            setState(() {
              var info = Map<String, String>.from(data);
              _deviceName = info[OverlayTabHandler.keyDeviceName] ?? '';
              _displayCode = info[OverlayTabHandler.keyDisplayCode] ?? '';
            });
          } else {
            log('set main info with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameSetOtp:
          if (data is Map<Object?, Object?>) {
            if (!mounted) return OverlayTabHandler.resultEmptyString;
            self.setState(() {
              var info = Map<String, String>.from(data);
              _otp = info[OverlayTabHandler.keyOtpCode] ?? '';
            });
          } else {
            log('set otp with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameLaunchApp:
          if (data is Map<Object?, Object?>) {
            AndroidWindow.launchApp();
          } else {
            log('launch app with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameUpdateTextSize:
          if (data is Map<Object?, Object?>) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.reload();
            await AppPreferences().loadTextSizeOption();
          } else {
            log('Update text size with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.actionShowZeroDialog:
          if (data is Map<Object?, Object?>) {
            if (!mounted) return OverlayTabHandler.resultEmptyString;
            setState(() {
              overlayType = OverlayType.retryDialog;
            });
          } else {
            log('set main info with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;
        case OverlayTabHandler.actionShowOverlayTab:
          if (data is Map<Object?, Object?>) {
            if (!mounted) return OverlayTabHandler.resultEmptyString;
            setState(() {
              overlayType = OverlayType.tab;
            });
          } else {
            log('set main info with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;
        case OverlayTabHandler.actionShowFpsKeeper:
          if (data is Map<Object?, Object?>) {
            if (!mounted) return OverlayTabHandler.resultEmptyString;
            setState(() {
              overlayType = OverlayType.fpsKeeper;
            });
          } else {
            log('set main info with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;
        case OverlayTabHandler.nameGetOverlayType:
          switch (overlayType) {
            case OverlayType.tab:
              return {
                OverlayTabHandler.keyOverlayType: OverlayTabHandler.valueTab
              };
            case OverlayType.retryDialog:
              return {
                OverlayTabHandler.keyOverlayType:
                    OverlayTabHandler.valueRetryDialog
              };
            case OverlayType.fpsKeeper:
              return {
                OverlayTabHandler.keyOverlayType:
                    OverlayTabHandler.valueFpsKeeper
              };
          }
      }
      return OverlayTabHandler.resultNullString;
    });
  }
}

class RetryDialog extends StatelessWidget {
  const RetryDialog(
      {super.key,
      required this.screenSize,
      required this.onRetry,
      required this.onStop});

  final Size screenSize;
  final VoidCallback onRetry;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final sc = ScrollController();
    return AndroidWindow(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 193),
                child: Container(
                  width: 320,
                  height: 200,
                  padding: const EdgeInsets.all(15),
                  decoration: ShapeDecoration(
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: context.tokens.radii.vsdslRadiusLg,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Screenshot Error",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.tokens.color
                              .vsdslColorNeutral /* AirSync-color-neutral */,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(13),
                      Expanded(
                        child: V3Scrollbar(
                          controller: sc,
                          child: SingleChildScrollView(
                            controller: sc,
                            child: SizedBox(
                              width: 300,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Unable to capture the screen and send it to the projection app. Would you like to restart the screenshot feature and try again, or stop the projection?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.tokens.color
                                          .vsdslColorNeutral /* AirSync-color-neutral */,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 45),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildButton(
                                V3ButtonInfo(
                                  text: "Stop",
                                  label: "Stop",
                                  identifier:
                                      'v3_qa_touchback_one_device_confirm',
                                  onTap: onStop,
                                  backgroundColor: Colors.transparent,
                                  borderColor:
                                      context.tokens.color.vsdslColorSecondary,
                                  textColor:
                                      context.tokens.color.vsdslColorSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildButton(
                                V3ButtonInfo(
                                  text: "Restart",
                                  label: "Restart",
                                  identifier:
                                      'v3_qa_touchback_one_device_cancel',
                                  onTap: onRetry,
                                  backgroundColor:
                                      context.tokens.color.vsdslColorPrimary,
                                  textColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(V3ButtonInfo info) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 45), // 關鍵保持高度
      child: V3Focus(
        label: info.label,
        identifier: info.identifier,
        child: InkWell(
          onTap: info.onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: ShapeDecoration(
              color: info.backgroundColor,
              shape: RoundedRectangleBorder(
                side: info.borderColor != null
                    ? BorderSide(width: 2, color: info.borderColor!)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Center(
              child: Text(
                info.text,
                textAlign: TextAlign.center,
                // softWrap: true,
                // overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: info.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum OverlayType { tab, retryDialog, fpsKeeper }

/// 極隱晦的 FPS 保持器：在角落畫一個 1×1 的微透明像素，
/// 透明度在 1~2/255 間切換，確保每 ~33ms 有可見差異讓畫面更新。
class StealthFpsKeeper extends StatefulWidget {
  const StealthFpsKeeper({
    super.key,
    this.fps = 30,
    this.alignment = AlignmentDirectional.bottomEnd,
    this.logicalSize = 1.0,
    this.color = Colors.black, // 深色背景建議用黑；淺色背景可改白
    this.padding = const EdgeInsets.all(1),
    this.enabled = true,
  }) : assert(fps > 0 && fps <= 120, 'fps must be in (0, 120].');

  /// 目標更新頻率（預設 30fps）
  final double fps;

  /// 小點擺放位置（預設右下角）
  final AlignmentGeometry alignment;

  /// 小點大小（邏輯像素，預設 1）
  final double logicalSize;

  /// 小點基底顏色（會套用極低 alpha）
  final Color color;

  /// 與邊緣的間距，避免被裁切
  final EdgeInsets padding;

  /// 是否啟用
  final bool enabled;

  /// 方便直接掛到根 Overlay；回傳 OverlayEntry，可自行移除。
  static OverlayEntry attachToOverlay(
    BuildContext context, {
    double fps = 30,
    AlignmentGeometry alignment = AlignmentDirectional.bottomEnd,
    double logicalSize = 1.0,
    Color color = Colors.black,
    EdgeInsets padding = const EdgeInsets.all(1),
  }) {
    final entry = OverlayEntry(
      builder: (_) => const IgnorePointer(
        ignoring: true,
        child: SizedBox.expand(
          child: _OverlayHost(), // 只為了占滿，真正的 widget 放在裡面
        ),
      ),
    );
    final overlay = Overlay.of(context, rootOverlay: true);
    overlay.insert(entry);

    // 把 keeper 再插入到 overlay host 上（避免攔指標、避免佔位）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (_OverlayHost.stateKey.currentState)?.setChild(
        StealthFpsKeeper(
          fps: fps,
          alignment: alignment,
          logicalSize: logicalSize,
          color: color,
          padding: padding,
        ),
      );
    });

    return entry;
  }

  @override
  State<StealthFpsKeeper> createState() => _StealthFpsKeeperState();
}

class _StealthFpsKeeperState extends State<StealthFpsKeeper> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _start();
  }

  @override
  void didUpdateWidget(covariant StealthFpsKeeper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fps != widget.fps || oldWidget.enabled != widget.enabled) {
      _stop();
      if (widget.enabled) _start();
    }
  }

  void _start() {
    final interval = Duration(milliseconds: (1000 / widget.fps).round());
    _timer = Timer.periodic(interval, (_) {
      if (!mounted) return;
      setState(() => _tick++); // 觸發極小幅度變化與重繪
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    final dot = SizedBox(
      width: widget.logicalSize,
      height: widget.logicalSize,
      child: RepaintBoundary(
        child: CustomPaint(
          isComplex: false,
          willChange: true,
          painter: _StealthDotPainter(
            tick: _tick,
            baseColor: widget.color,
          ),
        ),
      ),
    );

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: ExcludeSemantics(
          child: dot,
        ),
      ),
    );
  }
}

class _StealthDotPainter extends CustomPainter {
  _StealthDotPainter({required this.tick, required this.baseColor});

  final int tick;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 在 1 與 2（/255）之間切換 alpha：幾乎不可見，但每幀像素確實不同。
    final int alpha = 1 + (tick & 0x01);
    final paint = Paint()..color = baseColor.withAlpha(alpha);
    canvas.drawRect(Offset.zero & const Size(1, 1), paint);
  }

  @override
  bool shouldRepaint(covariant _StealthDotPainter oldDelegate) =>
      oldDelegate.tick != tick;
}

/// 內部用：給 attachToOverlay 占滿畫面並承載 StealthFpsKeeper。
class _OverlayHost extends StatefulWidget {
  const _OverlayHost();

  static final stateKey = GlobalKey<_OverlayHostState>();

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost> {
  Widget _child = const SizedBox.shrink();

  void setChild(Widget child) => setState(() => _child = child);

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: _OverlayHost.stateKey,
        child: _child,
      );
}
