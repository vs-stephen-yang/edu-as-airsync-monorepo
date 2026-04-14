import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class V3Scrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController controller;
  final bool thumbVisibility;
  final double mainAxisMargin;
  final Color? thumbColor;

  const V3Scrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.thumbVisibility = true,
    this.mainAxisMargin = 0.0,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    if (WebRTC.platformIsMobile) {
      return RawScrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        thickness: 4,
        radius: const Radius.circular(10),
        mainAxisMargin: mainAxisMargin,
        child: child,
      );
    }

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(thumbColor),
        thumbVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(8),
        mainAxisMargin: mainAxisMargin,
      ),
      child: Scrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        child: child,
      ),
    );
  }
}

class V3MenuScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController controller;
  final bool thumbVisibility;
  final double mainAxisMargin;

  const V3MenuScrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.thumbVisibility = true,
    this.mainAxisMargin = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return V3Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      mainAxisMargin: mainAxisMargin,
      thumbColor: Colors.grey.shade700,
      child: child,
    );
  }
}
