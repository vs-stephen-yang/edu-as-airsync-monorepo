import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
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
    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            V3ExtendCastingTimeMenu.showReamingTimeAlert,
          ]),
          builder: (BuildContext context, Widget? child) {
            if (V3ExtendCastingTimeMenu.showReamingTimeAlert.value) {
              return const V3ExtendSharingTimeMenu();
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class V3ExtendSharingTimeMenu extends StatefulWidget {
  const V3ExtendSharingTimeMenu({super.key});

  @override
  State<StatefulWidget> createState() => _V3ExtendSharingTimeMenuState();
}

class _V3ExtendSharingTimeMenuState extends State<V3ExtendSharingTimeMenu> {
  bool onlyCountdown = false;

  @override
  void initState() {
    ConnectionTimer.getInstance()
        .remainingTimeTimeout
        .stream
        .where((event) =>
            ConnectionTimer.getInstance().exceedMaxExtendTimes &&
            event < (ConnectionTimer.hintStartTimeSec - 5) &&
            !onlyCountdown)
        .listen((event) {
      // According to the design, the dialog will be changed to countdown view when after 5 seconds of the last countdown.
      if (!mounted) return;
      setState(() {
        onlyCountdown = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return onlyCountdown
        ? _buildPureCountdownView(context)
        : _buildMainDialog(context);
  }

  Widget _buildPureCountdownView(BuildContext context) {
    final isCompat = context.splitScreenRatio.widthFraction <=
        SplitScreenRatio.floatingDefault.widthFraction;
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

    if (isCompat) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: EdgeInsets.only(
            top: ChannelProvider.isModeratorMode ? 25 : 4.66,
          ),
          child: Center(child: r),
        ),
      );
    }

    return r;
  }

  Widget _buildMainDialog(BuildContext context) {
    final lastTime = ConnectionTimer.getInstance().exceedMaxExtendTimes;
    final height = lastTime ? 100.0 : 154.0;
    final message = lastTime
        ? S.of(context).v3_last_casting_time_countdown
        : S.of(context).v3_casting_time_countdown(
              ConnectionTimer.getInstance().remainExtendTime,
            );

    final compat = UnconstrainedBox(
      constrainedAxis: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // 移除圓角
          ),
          insetPadding: EdgeInsets.zero,
          backgroundColor: context.tokens.color.vsdslColorSurface1000,
          child: Stack(
            children: [
              Positioned.fill(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const _CountdownText(),
                  Spacer(),
                  const SizedBox(height: 8),
                  _MessageText(message: message),
                  Spacer(),
                  if (!lastTime) ...[
                    const SizedBox(height: 13),
                    _ExtendButtons(
                        wrapAlignment: WrapAlignment.spaceEvenly,
                        onDoNotExtend: () {
                          if (!mounted) return;
                          setState(() => onlyCountdown = true);
                        }),
                  ],
                  const SizedBox(height: 8),
                ],
              )),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _CountDownProgressIndicatorBar(),
              ),
            ],
          ),
        ),
      ),
    );
    return MultiWindowAdaptiveLayout(
      launcher: compat,
      floatingDefault: compat,
      landscape: _buildDialog(
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
            _MessageText(message: message),
            if (!lastTime) ...[
              const SizedBox(height: 13),
              _ExtendButtons(onDoNotExtend: () {
                if (!mounted) return;
                setState(() => onlyCountdown = true);
              }),
            ],
          ],
        ),
      ),
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

  const _MessageText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
