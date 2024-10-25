import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
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

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: context.tokens.radii.vsdswRadius2xl),
      backgroundColor: context.tokens.color.vsdswColorSurface100,
      shadowColor: context.tokens.color.vsdswColorOpacityNeutralMd,
      child: Container(
        width: isMobile ? 359 : 504,
        height: isMobile ? 360 : 332,
        padding: EdgeInsets.symmetric(
          vertical: context.tokens.spacing.vsdswSpacing2xl.top,
          horizontal: context.tokens.spacing.vsdswSpacingXl.left,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AutoSizeText(
                  stringTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.tokens.color.vsdswColorOnSurface,
                  ),
                ),
                SizedBox(height: context.tokens.spacing.vsdswSpacingMd.top),
                AutoSizeText(
                  stringContent,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.tokens.color.vsdswColorOnSurfaceVariant,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 1,
                    color: context.tokens.color.vsdswColorOutline,
                  ),
                  SizedBox(height: context.tokens.spacing.vsdswSpacingLg.top),
                  ElevatedButton(
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
                    child: AutoSizeText(stringAction),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
