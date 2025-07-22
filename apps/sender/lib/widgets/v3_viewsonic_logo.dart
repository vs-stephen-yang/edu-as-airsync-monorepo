import 'dart:io';

import 'package:display_cast_flutter/screens/debug_switch.dart';
import 'package:flutter/material.dart';

class V3ViewsonicLogo extends StatefulWidget {
  const V3ViewsonicLogo({super.key});

  @override
  State<V3ViewsonicLogo> createState() => _V3ViewsonicLogoState();
}

class _V3ViewsonicLogoState extends State<V3ViewsonicLogo> {
  static const int openDebugCounter = 5;
  int debugCounter = 0;

  void _onLogoTap() {
    debugCounter++;
    if (debugCounter == openDebugCounter) {
      debugCounter = 0;
      _showMenuDialog(const DebugSwitch());
    }
  }

  Future<void> _showMenuDialog(Widget dialogWidget) async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => dialogWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugCounter = 0;
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final logoPath = isMobile
        ? 'assets/images/ic_logo_viewsonic_mobile.png'
        : 'assets/images/ic_logo_viewsonic_desktop.png';
    final logoSize = isMobile ? const Size(170, 50) : const Size(193, 60);
    final padding = isMobile
        ? const EdgeInsets.fromLTRB(0, 0, 0, 24)
        : const EdgeInsets.only(right: 24, bottom: 16);

    return Positioned(
      left: isMobile ? 0 : null,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: padding,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: _onLogoTap,
            child: Image.asset(
              logoPath,
              width: logoSize.width,
              height: logoSize.height,
            ),
          ),
        ),
      ),
    );
  }
}
