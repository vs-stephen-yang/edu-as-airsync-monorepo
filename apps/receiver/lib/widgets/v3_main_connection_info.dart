import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_main_miracast_instruction.dart';
import 'package:display_flutter/widgets/v3_main_miracast_not_support_hint.dart';
import 'package:display_flutter/widgets/v3_main_qr_code_area.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Main connection information component for full screen and 2/3 screen layouts
///
/// Layout structure:
/// - Horizontal split: Instruction area (left) + QR code area (right)
/// - Bottom section: Miracast instructions
///
/// Used by:
/// - V3MainInfoLandscape (landscape and landscapeTwoThirds)
/// - Portrait layouts
class V3MainConnectionInfo extends StatefulWidget {
  const V3MainConnectionInfo({super.key});

  @override
  State<V3MainConnectionInfo> createState() => _V3MainConnectionInfoState();
}

class _V3MainConnectionInfoState extends State<V3MainConnectionInfo> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppPreferences().textSizeOptionNotifier,
      builder: (context, value, child) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: V3MainInstructionArea(
                      scrollController: _scrollController,
                    ),
                  ),
                  const V3MainQrCodeArea(),
                ],
              ),
            ),
            const V3MainInstructionSection(),
            const Gap(30.0),
          ],
        );
      },
    );
  }
}

/// Flexible instruction area container
///
/// Provides scrollable container for instruction content with configurable:
/// - Padding on all sides
/// - Scroll physics
/// - Custom child widget
///
/// Design pattern: Container + Scrollbar + SingleChildScrollView
/// Used across all screen size variants for consistent scrolling behavior
class V3MainInstructionArea extends StatelessWidget {
  final ScrollController scrollController;
  final double leftPadding;
  final double topPadding;
  final Widget? child;

  const V3MainInstructionArea({
    super.key,
    required this.scrollController,
    this.leftPadding = 53.0,
    this.topPadding = 53.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(
        left: leftPadding,
        top: topPadding,
      ),
      child: V3Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          controller: scrollController,
          child: child ?? const V3Instruction(isCastToDevice: false),
        ),
      ),
    );
  }
}

/// Bottom instruction section for Miracast-related information
///
/// Contains:
/// - Miracast connection instructions
/// - Miracast not supported hints
///
/// Displayed at bottom of all screen size variants
class V3MainInstructionSection extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;

  const V3MainInstructionSection({
    super.key,
    this.horizontalPadding = 85.0,
    this.verticalPadding = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const V3MainMiracastInstruction(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: const V3MainMiracastNotSupportHint(),
        ),
      ],
    );
  }
}
