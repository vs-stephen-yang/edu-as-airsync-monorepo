import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:sprintf/sprintf.dart';

class V3Toast {
  static final V3Toast _instance = V3Toast._internal();

  //private "Named constructors"
  V3Toast._internal();

  // passes the instantiation to the _instance object
  factory V3Toast() => _instance;

  final int second = 3;

  void makeSharingTimeToast(
      BuildContext context, String fullText, String sharingTime) {
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1);
    MotionToast(
      position: MotionToastPosition.bottom,
      animationType: AnimationType.fromBottom,
      constraints: BoxConstraints(
          minHeight: 78, minWidth: 320.0 * textScaleFactor, maxHeight: 150),
      primaryColor: context.tokens.color.vsdswColorNeutral,
      secondaryColor: context.tokens.color.vsdswColorNeutralInverse,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.tokens.spacing.vsdswSpacingMd.left,
        vertical: context.tokens.spacing.vsdswSpacingSm.top,
      ),
      borderRadius: 10,
      description: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 24,
            color: context.tokens.color.vsdswColorNeutralInverse,
          ),
          SizedBox(width: context.tokens.spacing.vsdswSpacingXs.left),
          SizedBox(
            width: 246 * textScaleFactor,
            child: Text.rich(
              _buildSharingTimeTextSpan(
                fullText: fullText,
                sharingTime: sharingTime,
                formatTexts: ['%s'],
                formatStyle: TextStyle(
                  // fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: context.tokens.color.vsdswColorSecondary,
                ),
              ),
              maxLines: 2,
              style: TextStyle(
                // fontSize: 16,
                color: context.tokens.color.vsdswColorNeutralInverse,
              ),
            ),
          ),
        ],
      ),
      displaySideBar: false,
      enableAnimation: false,
    ).show(context);
    SemanticsService.announce(
      sprintf(fullText, [sharingTime]),
      TextDirection.ltr,
    );
  }

  TextSpan _buildSharingTimeTextSpan(
      {required String fullText,
      required String sharingTime,
      required List<String> formatTexts,
      required TextStyle formatStyle}) {
    List<TextSpan> spans = [];
    int start = 0;

    // Process text based on each substring that needs to be formatted
    while (start < fullText.length) {
      int closestBoldStart = -1;
      String? closestBoldText;

      // Find the earliest occurrence of format text
      for (String boldText in formatTexts) {
        int index = fullText.indexOf(boldText, start);
        if (index != -1 &&
            (closestBoldStart == -1 || index < closestBoldStart)) {
          closestBoldStart = index;
          closestBoldText = boldText;
        }
      }

      // If there is no more format text, add the remaining text
      if (closestBoldStart == -1) {
        spans.add(TextSpan(
          text: fullText.substring(start),
        ));
        break;
      }

      // Add the normal part before the format text
      if (closestBoldStart > start) {
        spans.add(TextSpan(
          text: fullText.substring(start, closestBoldStart),
        ));
      }

      // Add format text
      spans.add(TextSpan(
        text: sharingTime,
        style: formatStyle,
      ));

      // Update the start position
      start = closestBoldStart + closestBoldText!.length;
    }
    return TextSpan(children: spans);
  }
}
