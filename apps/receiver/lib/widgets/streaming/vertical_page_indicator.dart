import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';

class VerticalPageIndicator extends StatelessWidget {
  final int pageIndex;
  final int dotCount;
  final VoidCallback onNextPressed;

  const VerticalPageIndicator({
    super.key,
    required this.pageIndex,
    required this.onNextPressed,
    this.dotCount = 3,
  });

  Widget _buildDot(BuildContext context, int index) {
    bool isActive = index == pageIndex;
    return Container(
      margin: const EdgeInsets.all(6),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive
            ? context.tokens.color.vsdslColorSecondaryVariant
            : context.tokens.color.vsdslColorOpacityPrimaryLg,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: HybridConnectionList().enlargedScreenIndex,
      builder: (_, enlarged, __) {
        if (dotCount <= 1 || enlarged != null) {
          return const SizedBox.shrink();
        }
        return Container(
          width: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.tokens.color.vsdslColorOutlineVariant,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < dotCount; i++) _buildDot(context, i),
              V3Focus(
                label: S.current.v3_lbl_streaming_page_control,
                identifier: 'v3_streaming_page_control',
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: IconButton(
                    onPressed: onNextPressed,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    color: context.tokens.color.vsdslColorOnSecondary,
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    splashRadius: 24,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          context.tokens.color.vsdslColorSecondaryVariant),
                      shape: WidgetStateProperty.all(const CircleBorder()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
