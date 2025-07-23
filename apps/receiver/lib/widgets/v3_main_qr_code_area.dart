import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:flutter/material.dart';

class V3MainQrCodeArea extends StatelessWidget {
  final double rightMargin;
  final double width;
  final double maxHeight;

  const V3MainQrCodeArea({
    super.key,
    this.rightMargin = 43.0,
    this.width = 171.0,
    this.maxHeight = 230.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: rightMargin),
      width: width,
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: _buildDecoration(context),
      child: const V3QrCodeQuickConnect(),
    );
  }

  ShapeDecoration _buildDecoration(BuildContext context) {
    return ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.radii.vsdslRadiusXl,
        side: BorderSide(
          width: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
      ),
    );
  }
}
