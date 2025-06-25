import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
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
                                AutoSizeText(
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
                                AutoSizeText(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: V3Focus(
                                label: item1Label,
                                identifier: item1Identifier,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        context.tokens.color.vsdslColorPrimary,
                                    backgroundColor: Colors.white,
                                    // remove onFocused color, this is also ripple color
                                    overlayColor: Colors.transparent,
                                    side: BorderSide(
                                      color: context
                                          .tokens.color.vsdslColorPrimary,
                                      width: 1,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: onItem1,
                                  child: AutoSizeText(
                                    item1,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: V3Focus(
                                label: item2Label,
                                identifier: item2Identifier,
                                child: ElevatedButton(
                                  focusNode: primaryFocusNode,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5.0,
                                    shadowColor:
                                        context.tokens.color.vsdslColorPrimary,
                                    foregroundColor: context.tokens.color
                                        .vsdslColorOnSurfaceInverse,
                                    backgroundColor:
                                        context.tokens.color.vsdslColorPrimary,
                                    // remove onFocused color, this is also ripple color
                                    overlayColor: Colors.transparent,
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: onItem2,
                                  child: AutoSizeText(
                                    item2,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
