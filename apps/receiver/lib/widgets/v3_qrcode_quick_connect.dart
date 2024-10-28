import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_qrcode_image.dart';
import 'package:flutter/material.dart';

class V3QrCodeQuickConnect extends StatelessWidget {
  const V3QrCodeQuickConnect(
      {super.key, this.isStringOnTop = false, this.size = 139});

  final bool isStringOnTop;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget title = AutoSizeText(
      S.of(context).v3_qrcode_quick_connect,
      style: TextStyle(
        color: context.tokens.color.vsdslColorNeutral,
        fontWeight: FontWeight.w600,
        fontSize: isStringOnTop ? 21 : 14,
      ),
    );

    Widget space = SizedBox(
        height: isStringOnTop
            ? context.tokens.spacing.vsdslSpacing3xl.top - 1
            : context.tokens.spacing.vsdslSpacingXl.top - 1);

    List<Widget> children = [];
    children.add(title);
    children.add(space);
    children.add(const V3QrCodeImage(isShowBackground: true));

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: context.tokens.spacing.vsdslSpacing4xl.top - 1),
      child: Column(
        children: isStringOnTop ? children : children.reversed.toList(),
      ),
    );
  }
}
