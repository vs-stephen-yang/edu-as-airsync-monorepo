import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:flutter/material.dart';

class V3AutoHyphenatingText extends StatelessWidget {
  final String text;
  final String? semanticsLabel;
  final TextStyle? style;
  final TextAlign? textAlign;

  const V3AutoHyphenatingText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    // ❌ The following settings are NOT recommended:
    // maxLines: 1,
    // overflow: TextOverflow.ellipsis,

    // ✅ Reasons:
    // 1. For WCAG 1.4.4: Resize Text
    //    - Users may enable large text. If maxLines: 1 is set, the text may be truncated and unreadable.
    // 2. For WCAG 1.1.1: Non-text Content + 1.3.1: Info and Relationships
    //    - Truncated text may fail to convey complete information, which is a barrier for both visual and non-visual users.
    // 3. If visual truncation is still required, use a Tooltip or Semantics label to provide the full text information.
    return AutoHyphenatingText(
      text,
      style: style,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
    );
  }
}
