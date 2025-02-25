import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';

class V3ExtendCastingTimeMenu extends StatefulWidget {
  const V3ExtendCastingTimeMenu({super.key});

  static ValueNotifier<bool> showReamingTimeAlert = ValueNotifier(false);

  @override
  State createState() => _V3ExtendCastingTimeMenuState();
}

class _V3ExtendCastingTimeMenuState extends State<V3ExtendCastingTimeMenu> {
  StreamSubscription<int>? sub;

  @override
  void initState() {
    super.initState();
    sub = ConnectionTimer.getInstance()
        .remainingTimeTimeout
        .stream
        .where((event) =>
            event == 0 && !V3ExtendCastingTimeMenu.showReamingTimeAlert.value)
        .listen((event) {
      if (!mounted) return;

      V3Toast()
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
              return const _V3ExtendSharingTimeMenu();
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _V3ExtendSharingTimeMenu extends StatefulWidget {
  const _V3ExtendSharingTimeMenu({super.key});

  @override
  State<_V3ExtendSharingTimeMenu> createState() =>
      _V3ExtendSharingTimeMenuState();
}

class _V3ExtendSharingTimeMenuState extends State<_V3ExtendSharingTimeMenu> {
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
    return _buildDialog(
      context: context,
      width: 108,
      height: 50,
      backgroundColor: const Color(0xFF151C32).withOpacity(0.64),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          _CountdownText(),
        ],
      ),
    );
  }

  Widget _buildMainDialog(BuildContext context) {
    final lastTime = ConnectionTimer.getInstance().exceedMaxExtendTimes;
    final height = lastTime ? 100.0 : 154.0;
    final message = lastTime
        ? S.of(context).v3_last_casting_time_countdown
        : S.of(context).v3_casting_time_countdown(
              ConnectionTimer.getInstance().remainExtendTime,
            );

    return _buildDialog(
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
            _ExtendButtons(
                onDoNotExtend: () => setState(() => onlyCountdown = true)),
          ],
        ],
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
        return Text(
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

  const _ExtendButtons({required this.onDoNotExtend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.vsdslSpacingXl.right),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          _buildButton(
            context: context,
            label: S.of(context).v3_casting_time_do_not_extend,
            width: 110,
            backgroundColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            borderColor: context.tokens.color.vsdslColorOnSurfaceInverse,
            onPressed: onDoNotExtend,
          ),
          _buildButton(
            context: context,
            label: S.of(context).v3_casting_time_extend,
            width: 67,
            backgroundColor: context.tokens.color.vsdslColorOnSurfaceInverse,
            textColor: context.tokens.color.vsdslColorNeutral,
            onPressed: () {
              V3ExtendCastingTimeMenu.showReamingTimeAlert.value = false;
              ConnectionTimer.getInstance().extendRemainTimer();
              V3Toast()
                  .makeSuccessToast(context,
                      S.of(context).v3_casting_time_extend_success_toast)
                  .show(context);
            },
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
  }) {
    return V3Focus(
      child: SizedBox(
        width: width,
        height: 27,
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
