import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class V3Setting2ndLayer extends StatelessWidget {
  const V3Setting2ndLayer({
    super.key,
    required this.child,
    this.isDisable = false,
    this.isDisableFromNotSupport = false,
    this.disableScroll = false,
    this.showEnergySaving = false,
  });

  final Widget child;
  final bool isDisable;
  final bool isDisableFromNotSupport;
  final bool disableScroll;
  final bool showEnergySaving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.tokens.spacing.vsdslSpacingXl.left,
        top: 57,
        right: context.tokens.spacing.vsdslSpacingXl.right,
        bottom: context.tokens.spacing.vsdslSpacingXl.bottom,
      ),
      child: Column(
        children: [
          Expanded(
            child: disableScroll
                ? child
                : Builder(
                    builder: (context) {
                      final ScrollController scrollController =
                          ScrollController();
                      return V3Scrollbar(
                        controller: scrollController,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.only(right: 8),
                          child: child,
                        ),
                      );
                    },
                  ),
          ),
          _WarningMessagesContainer(
            isDisable: isDisable,
            isDisableFromNotSupport: isDisableFromNotSupport,
            showEnergySaving: showEnergySaving,
          ),
        ],
      ),
    );
  }
}

class _WarningMessagesContainer extends StatelessWidget {
  const _WarningMessagesContainer({
    required this.isDisable,
    required this.isDisableFromNotSupport,
    required this.showEnergySaving,
  });

  final bool isDisable;
  final bool isDisableFromNotSupport;
  final bool showEnergySaving;

  @override
  Widget build(BuildContext context) {
    final bool hasWarnings = isDisable || isDisableFromNotSupport;
    final bool hasEnergySaving = showEnergySaving;

    if (!hasWarnings && !hasEnergySaving) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDisable)
            _WarningMessage(
              message: S.of(context).v3_settings_feature_locked,
            ),
          if (isDisable && isDisableFromNotSupport) const Gap(8),
          if (isDisableFromNotSupport)
            _WarningMessage(
              message: S.of(context).v3_miracast_not_support,
            ),
          if (hasWarnings && hasEnergySaving) const Gap(8),
          if (hasEnergySaving) _EnergySavingWidget(),
        ],
      ),
    );
  }
}

class _WarningMessage extends StatelessWidget {
  const _WarningMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      decoration: BoxDecoration(
        color: context.tokens.color.vsdslColorSurface900,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: context.tokens.spacing.vsdslSpacingXl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: SvgPicture.asset(
              'assets/images/ic_toast_alert.svg',
              width: 16,
              height: 16,
            ),
          ),
          Gap(context.tokens.spacing.vsdslSpacingLg.right),
          Expanded(
            child: V3AutoHyphenatingText(
              message,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: context.tokens.color.vsdslColorWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnergySavingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      decoration: BoxDecoration(
        borderRadius: context.tokens.radii.vsdslRadiusLg,
        color: context.tokens.color.vsdslColorSurface900,
      ),
      padding: context.tokens.spacing.vsdslSpacingXl,
      child: V3AutoHyphenatingText(
        S.of(context).v3_settings_broadcast_screen_energy_saving,
        style: TextStyle(
          color: context.tokens.color.vsdslColorOnTertiary,
          fontSize: 12,
        ),
      ),
    );
  }
}
