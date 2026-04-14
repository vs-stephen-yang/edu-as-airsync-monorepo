import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_dialog_action_buttons.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class V3CustomDialog extends StatelessWidget {
  static const double height = 193;

  const V3CustomDialog({
    super.key,
    this.offset,
    required this.alignmentGeometry,
    required this.title,
    required this.content,
    required this.item1,
    required this.item2,
    required this.onItem1,
    required this.onItem2,
    required this.primaryFocusNode,
    required this.width,
    this.item1Label,
    this.item1Identifier,
    this.item2Label,
    this.item2Identifier,
  });

  final Offset? offset;
  final AlignmentGeometry alignmentGeometry;
  final String title, content;
  final String item1, item2;
  final VoidCallback onItem1, onItem2;
  final FocusNode primaryFocusNode;
  final String? item1Label, item1Identifier;
  final String? item2Label, item2Identifier;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bigTextScalar = MediaQuery.of(context).textScaler.scale(1.0) > 1.0;
    final ScrollController scrollController = ScrollController();
    return Stack(
      children: [
        Positioned(
          top: offset?.dy ?? 0,
          left: offset?.dx ?? 0,
          child: UnconstrainedBox(
            // Use UnconstrainedBox to override Dialog minimum size
            // https://blog.csdn.net/shving/article/details/114485776
            constrainedAxis: Axis.vertical,
            child: SizedBox(
              width: width,
              height: height,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: context.tokens.radii.vsdslRadiusXl,
                ),
                insetPadding: EdgeInsets.zero,
                backgroundColor:
                    context.tokens.color.vsdslColorOnSurfaceInverse,
                elevation: 16.0,
                shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: V3Scrollbar(
                          controller: scrollController,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                V3AutoHyphenatingText(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        context.tokens.color.vsdslColorNeutral,
                                  ),
                                ),
                                const Gap(13),
                                Text(
                                  content,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        context.tokens.color.vsdslColorNeutral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                      V3DialogActionButtons(
                        leftButton: V3ButtonInfo(
                          text: item1,
                          label: item1Label,
                          identifier: item1Identifier,
                          onTap: onItem1,
                          backgroundColor: Colors.white,
                          borderColor: context.tokens.color.vsdslColorPrimary,
                          textColor: context.tokens.color.vsdslColorPrimary,
                          padding: EdgeInsets.all(bigTextScalar ? 5 : 0),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        rightButton: V3ButtonInfo(
                          text: item2,
                          label: item2Label,
                          identifier: item2Identifier,
                          onTap: onItem2,
                          backgroundColor:
                              context.tokens.color.vsdslColorPrimary,
                          textColor:
                              context.tokens.color.vsdslColorOnSurfaceInverse,
                          shadowColor: context.tokens.color.vsdslColorPrimary,
                          focusNode: primaryFocusNode,
                          padding: EdgeInsets.all(bigTextScalar ? 5 : 0),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
