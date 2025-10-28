import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class V3Setting2ndLayer extends StatefulWidget {
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
  State<V3Setting2ndLayer> createState() => _V3Setting2ndLayerState();
}

class _V3Setting2ndLayerState extends State<V3Setting2ndLayer> {
  double _warningMessagesHeight = 0;

  void _onHeightMeasured(double height) {
    if (_warningMessagesHeight != height) {
      if (!mounted) return;
      setState(() {
        _warningMessagesHeight = height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用 LayoutBuilder 獲取實際可用的高度
        final double availableHeight = constraints.maxHeight;
        final double maxWarningHeight = availableHeight * 0.5; // 50% 的實際可用高度

        return Stack(
          children: [
            // 主要內容區域
            Positioned(
              left: context.tokens.spacing.vsdslSpacingXl.left,
              top: 57,
              right: context.tokens.spacing.vsdslSpacingXl.right,
              bottom: context.tokens.spacing.vsdslSpacingXl.bottom +
                  _warningMessagesHeight,
              child: widget.disableScroll
                  ? widget.child
                  : Builder(
                      builder: (context) {
                        final ScrollController scrollController =
                            ScrollController();
                        return V3Scrollbar(
                          controller: scrollController,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.only(right: 8),
                            child: widget.child,
                          ),
                        );
                      },
                    ),
            ),
            // 警告訊息容器
            Positioned(
              left: context.tokens.spacing.vsdslSpacingXl.left,
              right: context.tokens.spacing.vsdslSpacingXl.right,
              bottom: context.tokens.spacing.vsdslSpacingXl.bottom,
              child: _WarningMessagesContainer(
                isDisable: widget.isDisable,
                isDisableFromNotSupport: widget.isDisableFromNotSupport,
                onHeightMeasured: _onHeightMeasured,
                maxHeight: maxWarningHeight,
                showEnergySaving: widget.showEnergySaving,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WarningMessagesContainer extends StatefulWidget {
  const _WarningMessagesContainer({
    required this.isDisable,
    required this.isDisableFromNotSupport,
    required this.onHeightMeasured,
    required this.maxHeight,
    required this.showEnergySaving,
  });

  final bool isDisable;
  final bool isDisableFromNotSupport;
  final ValueChanged<double> onHeightMeasured;
  final double maxHeight;
  final bool showEnergySaving;

  @override
  State<_WarningMessagesContainer> createState() =>
      _WarningMessagesContainerState();
}

class _WarningMessagesContainerState extends State<_WarningMessagesContainer> {
  final GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureHeight();
    });
  }

  @override
  void didUpdateWidget(_WarningMessagesContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureHeight();
    });
  }

  void _measureHeight() {
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final height = renderBox.size.height;
      // 回報實際使用的高度（可能被限制在 maxHeight 內）
      final actualHeight =
          height > widget.maxHeight ? widget.maxHeight : height;
      widget.onHeightMeasured(actualHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 檢查是否需要顯示警告訊息或節能內容
    final bool hasWarnings = widget.isDisable || widget.isDisableFromNotSupport;
    final bool hasEnergySaving = widget.showEnergySaving;

    if (!hasWarnings && !hasEnergySaving) {
      // 沒有任何內容時，回報高度為 0
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onHeightMeasured(0);
      });
      return const SizedBox.shrink();
    }

    final bottomAreaContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 警告訊息區域
        if (widget.isDisable)
          _WarningMessage(
            message: S.of(context).v3_settings_feature_locked,
          ),
        if (widget.isDisable && widget.isDisableFromNotSupport) const Gap(8),
        if (widget.isDisableFromNotSupport)
          _WarningMessage(
            message: S.of(context).v3_miracast_not_support,
          ),
        // 節能內容區域
        if (hasWarnings && hasEnergySaving) const Gap(8),
        if (hasEnergySaving) _EnergySavingWidget(),
      ],
    );

    return Container(
      key: _containerKey,
      padding: EdgeInsets.only(top: 5),
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
      ),
      child: Builder(builder: (context) {
        final sc = ScrollController();
        return V3Scrollbar(
          controller: sc,
          child: SingleChildScrollView(
            controller: sc,
            child: bottomAreaContent,
          ),
        );
      }),
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
