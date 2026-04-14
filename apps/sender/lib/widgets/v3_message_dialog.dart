import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3MessageDialog extends StatelessWidget {
  const V3MessageDialog({
    super.key,
    this.stringTitle = '',
    this.stringContent = '',
    this.stringAction = '',
  });

  final String stringTitle;
  final String stringContent;
  final String stringAction;

  @override
  Widget build(BuildContext context) {
    bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final sc = ScrollController();
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: context.tokens.radii.vsdswRadius2xl),
      backgroundColor: context.tokens.color.vsdswColorSurface100,
      shadowColor: context.tokens.color.vsdswColorOpacityNeutralMd,
      child: Container(
        width: isMobile ? 359 : 504,
        height: isMobile ? 360 : 332,
        padding: context.tokens.spacing.vsdswSpacingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V3AutoHyphenatingText(
              stringTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: context.tokens.color.vsdswColorOnSurface,
              ),
            ),
            SizedBox(height: context.tokens.spacing.vsdswSpacingMd.top),
            Expanded(
              child: V3Scrollbar(
                controller: sc,
                child: SingleChildScrollView(
                  controller: sc,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      V3AutoHyphenatingText(
                        stringContent,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              context.tokens.color.vsdswColorOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: context.tokens.color.vsdswColorOutline,
            ),
            SizedBox(height: context.tokens.spacing.vsdswSpacingMd.top),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ElevatedButton(
                onPressed: () {
                  navService.goBack();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                  shadowColor: context.tokens.color.vsdswColorPrimary,
                  foregroundColor: context.tokens.color.vsdswColorOnPrimary,
                  backgroundColor: context.tokens.color.vsdswColorPrimary,
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: V3AutoHyphenatingText(stringAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
