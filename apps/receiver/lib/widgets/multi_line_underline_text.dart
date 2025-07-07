import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/widgets/text_size_aware.dart';
import 'package:flutter/material.dart';

class MultiLineUnderlineText extends TextSizeAwareStateless {
  final String text;
  final TextStyle style;
  final double underlineThickness;
  final Color underlineColor;

  const MultiLineUnderlineText({
    super.key,
    required this.text,
    required this.style,
    this.underlineThickness = 1,
    this.underlineColor = Colors.grey,
  });

  @override
  Widget buildWithTextSize(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
            text: text,
            style: style.copyWith(
                fontSize: (style.fontSize ?? 10) * AppPreferences().textScale));
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);
        final lines = getLines(tp, text);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < lines.length; i++) ...[
              Text(lines[i].text, style: style),
              Container(
                width: lines[i].width,
                height: underlineThickness,
                color: underlineColor,
              )
            ]
          ],
        );
      },
    );
  }

  List<LineText> getLines(TextPainter textPainter, String fullText) {
    List<LineText> lines = [];
    int textLength = fullText.length;

    for (int i = 0; i < textPainter.computeLineMetrics().length; i++) {
      final lineMetric = textPainter.computeLineMetrics()[i];
      final startOffset = textPainter
          .getPositionForOffset(Offset(0, lineMetric.baseline))
          .offset;

      int endOffset;
      if (i + 1 < textPainter.computeLineMetrics().length) {
        final nextLineMetric = textPainter.computeLineMetrics()[i + 1];
        endOffset = textPainter
            .getPositionForOffset(Offset(0, nextLineMetric.baseline))
            .offset;
      } else {
        endOffset = textLength;
      }

      // 避免重複
      if (startOffset < endOffset && endOffset <= textLength) {
        lines.add(
          LineText(fullText.substring(startOffset, endOffset).trimRight(),
              lineMetric.width),
        );
      }
    }
    return lines;
  }
}

class LineText {
  LineText(this.text, this.width);

  final String text;
  final double width;
}
