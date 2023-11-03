import 'package:flutter/material.dart';

class MenuDialog extends StatelessWidget {
  const MenuDialog(
      {super.key,
      this.backgroundColor,
      this.alignment = Alignment.bottomLeft,
      this.edgeInsets = const EdgeInsets.fromLTRB(20, 0, 0, 140),
      this.menuSize,
      this.child});

  final Color? backgroundColor;
  final AlignmentGeometry? alignment;
  final EdgeInsets? edgeInsets;
  final Size? menuSize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: backgroundColor,
      alignment: alignment,
      insetPadding: edgeInsets,
      child: SizedBox(
        width: menuSize != null
            ? menuSize!.width
            : MediaQuery.of(context).size.width * 0.25,
        height: menuSize != null
            ? menuSize!.height
            : MediaQuery.of(context).size.height * 0.6,
        child: child,
      ),
    );
  }
}
