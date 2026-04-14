import 'package:flutter/material.dart';

class V3Scrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController controller;
  final bool thumbVisibility;

  const V3Scrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.thumbVisibility = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      thickness: 4,
      radius: const Radius.circular(10),
      child: child,
    );
  }
}
