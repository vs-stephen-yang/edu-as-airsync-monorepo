import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3BroadcastIndicator extends ConsumerStatefulWidget {
  const V3BroadcastIndicator({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _V3BroadcastIndicatorState();
}

class _V3BroadcastIndicatorState extends ConsumerState {
  final Color _highlightColor = const Color.fromRGBO(0xFE, 0xD1, 0x41, 1);
  final _isBroadcastOnScreen = false;

  @override
  Widget build(BuildContext context) {
    final isBroadcastingToGroup =
        ref.watch(groupProvider.select((state) => state.broadcastToGroup));
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isBroadcastingToGroup) ...[
          SizedBox(
            height: 24,
            child: ElevatedButton(
              onPressed: () {
                // todo: implement dialog.
                // _showBroadcastMenuDialog(context);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _isBroadcastOnScreen
                    ? context.tokens.color.vsdslColorOnSurface
                    : _highlightColor,
                shape: RoundedRectangleBorder(
                  borderRadius: context.tokens.radii.vsdslRadiusFull,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.tokens.spacing.vsdslSpacingMd.left,
                  vertical: context.tokens.spacing.vsdslSpacing2xs.top,
                ),
                minimumSize: const Size(50, 24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    width: 21,
                    height: 21,
                    image: const Svg('assets/images/ic_broadcast.svg'),
                    color: _isBroadcastOnScreen
                        ? _highlightColor
                        : context.tokens.color.vsdslColorOnSurface,
                  ),
                  SizedBox(width: context.tokens.spacing.vsdslSpacingXs.left),
                  Text(
                    S.of(context).v3_broadcast_indicator,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _isBroadcastOnScreen
                          ? _highlightColor
                          : context.tokens.color.vsdslColorOnSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: context.tokens.spacing.vsdslSpacingLg.left),
        ],
      ],
    );
  }
}
