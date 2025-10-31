import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3ExtendCastingTimeMenu extends StatefulWidget {
  const V3ExtendCastingTimeMenu({super.key});

  static ValueNotifier<bool> showReamingTimeAlert = ValueNotifier(false);

  @override
  State createState() => _V3ExtendCastingTimeMenuState();
}

class _V3ExtendCastingTimeMenuState extends State<V3ExtendCastingTimeMenu> {
  StreamSubscription<int>? sub;
  late V3Toast _v3Toast;

  @override
  void initState() {
    super.initState();
    _v3Toast = context.read<V3Toast>();

    sub = ConnectionTimer.getInstance()
        .remainingTimeTimeout
        .stream
        .where((event) =>
            event == 0 && !V3ExtendCastingTimeMenu.showReamingTimeAlert.value)
        .listen((event) {
      if (!mounted) return;
      _v3Toast
          .makeMessageToast(context, S.of(context).v3_casting_ended_toast)
          .show(context);
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: V3ExtendCastingTimeMenu.showReamingTimeAlert,
      builder: (ctx, showReamingTimeAlert, c) => Visibility(
        visible: showReamingTimeAlert,
        child: V3ExtendSharingTimeMenu(
          timer: ConnectionTimer.getInstance(),
        ),
      ),
    );
  }
}

class V3ExtendSharingTimeMenu extends StatefulWidget {
  final ConnectionTimer timer;
  static ValueNotifier<bool> onlyCountdown = ValueNotifier(false);

  const V3ExtendSharingTimeMenu({super.key, required this.timer});

  @override
  State<StatefulWidget> createState() => _V3ExtendSharingTimeMenuState();
}

class _V3ExtendSharingTimeMenuState extends State<V3ExtendSharingTimeMenu> {
  @override
  void initState() {
    widget.timer.remainingTimeTimeout.stream
        .where((event) =>
            widget.timer.exceedMaxExtendTimes &&
            event < (ConnectionTimer.hintStartTimeSec - 5) &&
            !V3ExtendSharingTimeMenu.onlyCountdown.value)
        .listen((event) {
      // According to the design, the dialog will be changed to countdown view when after 5 seconds of the last countdown.
      V3ExtendSharingTimeMenu.onlyCountdown.value = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: V3ExtendSharingTimeMenu.onlyCountdown,
        builder: (ctx, onlyCountdown, c) => onlyCountdown
            ? _buildPureCountdownView(context)
            : _buildMainDialog(context));
  }

  Widget _buildPureCountdownView(BuildContext context) {
    final r = _buildDialog(
      context: context,
      width: 108,
      height: 50,
      backgroundColor: const Color(0xFF151C32).withValues(alpha: 0.64),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          _CountdownText(),
        ],
      ),
    );

    if (context.splitScreenRatio.widthFraction <
        SplitScreenRatio.floatingDefault.widthFraction) {
      // ═══════════════════════════════════════════════════════════════
      // 小螢幕模式（launcher/launcherFull）
      // ═══════════════════════════════════════════════════════════════
      //
      // 在小螢幕模式下，倒數計時框會由 V3NotificationCenter 的 Stack
      // 自動對齊到頂部中央（alignment: Alignment.topCenter）
      // V3NotificationCenter 已經處理了避開 namelabel 的邏輯
      //
      return r; // 直接返回，由 Stack 的 alignment 控制位置
    }

    return r;
  }

  Widget _buildMainDialog(BuildContext context) {
    final lastTime = widget.timer.exceedMaxExtendTimes;
    final height = lastTime ? 100.0 : 154.0;
    final message = lastTime
        ? S.of(context).v3_last_casting_time_countdown
        : S.of(context).v3_casting_time_countdown(
              widget.timer.remainExtendTime,
            );

    final compat = Center(
      child: UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: SizedBox(
          /// based on spec, be full screen when screen is launcher width an height
          height: context.splitScreenRatio == SplitScreenRatio.launcher &&
                  MediaQuery.of(context).size.width <=
                      SplitScreenRatio.launcher.widthDP + 10 &&
                  MediaQuery.of(context).size.height <=
                      SplitScreenRatio.launcher.heightDP + 10
              ? MediaQuery.of(context).size.height
              : SplitScreenRatio.launcher.heightDP,
          width: MediaQuery.of(context).size.width,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // 移除圓角
            ),
            insetPadding: EdgeInsets.zero,
            backgroundColor: context.tokens.color.vsdslColorSurface1000,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 5,
                    maxHeight: 16,
                  ),
                  child: SizedBox.shrink(), // or any child you want
                ),
                const _CountdownText(),
                Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: 8,
                  ),
                  child: SizedBox.shrink(), // or any child you want
                ),
                _MessageText(
                  message: message,
                  height: 52,
                ),
                Spacer(),
                if (!lastTime) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 0,
                      maxHeight: 13,
                    ),
                    child: SizedBox.shrink(), // or any child you want
                  ),
                  _ExtendButtons(
                      wrapAlignment: WrapAlignment.spaceEvenly,
                      onDoNotExtend: () {
                        V3ExtendSharingTimeMenu.onlyCountdown.value = true;
                      }),
                ],
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 4,
                    maxHeight: 8,
                  ),
                  child: SizedBox.shrink(), // or any child you want
                ),
                _CountDownProgressIndicatorBar(),
              ],
            ),
          ),
        ),
      ),
    );
    final landscape = _buildDialog(
      context: context,
      width: 242,
      height: height,
      backgroundColor: context.tokens.color.vsdslColorSurface1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const _CountdownText(),
          const SizedBox(height: 8),
          _MessageText(
            message: message,
            height: lastTime ? 30 : 52,
          ),
          if (!lastTime) ...[
            const SizedBox(height: 13),
            _ExtendButtons(onDoNotExtend: () {
              V3ExtendSharingTimeMenu.onlyCountdown.value = true;
            }),
          ],
        ],
      ),
    );
    return MultiWindowAdaptiveLayout(
      launcher: compat,
      floatingDefault: landscape,
      landscape: landscape,
    );
  }

  Widget _buildDialog(
      {required BuildContext context,
      required double width,
      required double height,
      required Color backgroundColor,
      required Widget child}) {
    return UnconstrainedBox(
      constrainedAxis: Axis.vertical,
      child: SizedBox(
        width: width,
        height: height,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: context.tokens.radii.vsdslRadiusLg,
            side: BorderSide(
              color: context.tokens.color.vsdslColorOutlineVariant,
              width: 0.6,
            ),
          ),
          insetPadding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          child: ClipRRect(
            borderRadius: context.tokens.radii.vsdslRadiusLg,
            child: Stack(
              children: [
                Positioned.fill(child: child),
                const Positioned(
                  left: 2.5,
                  right: 2.5,
                  bottom: 0,
                  child: _CountDownProgressIndicatorBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownText extends StatelessWidget {
  const _CountdownText();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ConnectionTimer.getInstance().remainingTimeTimeout.stream,
      builder: (context, AsyncSnapshot<int> snapshot) {
        final value = snapshot.data ?? ConnectionTimer.hintStartTimeSec;
        return V3AutoHyphenatingText(
          Duration(seconds: value).toString().split('.').first.padLeft(8, "0"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.tokens.color.vsdslColorOnSurfaceInverse,
          ),
        );
      },
    );
  }
}

class _MessageText extends StatelessWidget {
  final String message;
  final double height;

  const _MessageText({required this.message, required this.height});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height,
        maxHeight: height,
      ),
      child: Builder(
        builder: (context) {
          final sc = ScrollController();
          return V3Scrollbar(
            controller: sc,
            child: SingleChildScrollView(
              controller: sc,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: AutoSizeText.rich(
                  TextSpan(
                    text: message,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  minFontSize: 8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExtendButtons extends StatelessWidget {
  final VoidCallback onDoNotExtend;
  final WrapAlignment wrapAlignment;

  const _ExtendButtons({
    required this.onDoNotExtend,
    this.wrapAlignment = WrapAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    final v3Toast = context.read<V3Toast>();

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.vsdslSpacingXl.right),
      child: Wrap(
        alignment: wrapAlignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          _buildButton(
            context: context,
            label: S.of(context).v3_casting_time_do_not_extend,
            width: 90,
            backgroundColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            borderColor: context.tokens.color.vsdslColorOnSurfaceInverse,
            onPressed: onDoNotExtend,
            semanticLabel: S.of(context).v3_lbl_extend_casting_do_not_extend,
            identifier: 'v3_qa_extend_casting_do_not_extend',
          ),
          _buildButton(
            context: context,
            label: S.of(context).v3_casting_time_extend,
            width: 90,
            backgroundColor: context.tokens.color.vsdslColorOnSurfaceInverse,
            textColor: context.tokens.color.vsdslColorNeutral,
            onPressed: () {
              V3ExtendCastingTimeMenu.showReamingTimeAlert.value = false;
              ConnectionTimer.getInstance().extendRemainTimer();
              v3Toast
                  .makeSuccessToast(context,
                      S.of(context).v3_casting_time_extend_success_toast)
                  .show(context);
            },
            semanticLabel: S.of(context).v3_lbl_extend_casting_extend,
            identifier: 'v3_qa_extend_casting_extend',
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required double width,
    required Color backgroundColor,
    Color? textColor,
    Color? borderColor,
    required VoidCallback onPressed,
    required String? semanticLabel,
    required String? identifier,
  }) {
    return V3Focus(
      label: semanticLabel,
      identifier: identifier,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 27,
          minWidth: width,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor:
                textColor ?? context.tokens.color.vsdslColorOnSurfaceInverse,
            backgroundColor: backgroundColor,
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
            textStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 13),
          ),
          onPressed: onPressed,
          child: AutoSizeText(label, minFontSize: 8),
        ),
      ),
    );
  }
}

class _CountDownProgressIndicatorBar extends StatelessWidget {
  const _CountDownProgressIndicatorBar();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ConnectionTimer.getInstance().remainingTimeTimeout.stream,
      builder: (context, AsyncSnapshot<int> snapshot) {
        final value = snapshot.data ?? ConnectionTimer.hintStartTimeSec;
        return LinearProgressIndicator(
          value: value / ConnectionTimer.hintStartTimeSec,
          minHeight: 5,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            context.tokens.color.vsdslColorWarning,
          ),
        );
      },
    );
  }
}
