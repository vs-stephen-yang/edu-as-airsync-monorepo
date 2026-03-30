import 'dart:io';

import 'package:display_cast_flutter/screens/debug_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class V3DebugInvisibleButton extends StatefulWidget {
  const V3DebugInvisibleButton({super.key});

  @override
  State<V3DebugInvisibleButton> createState() => _V3DebugInvisibleButtonState();
}

class _V3DebugInvisibleButtonState extends State<V3DebugInvisibleButton> {
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
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final buttonSize = const Size(100, 50);
    final padding = isMobile
        ? const EdgeInsets.fromLTRB(0, 0, 0, 24)
        : const EdgeInsets.only(right: 24, bottom: 16);

    return Positioned(
      right: isMobile ? null : 0,
      bottom: 0,
      child: Padding(
        padding: padding,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: _onLogoTap,
            child: Container(
              color: Colors.transparent,
              width: buttonSize.width,
              height: buttonSize.height,
            ),
          ),
        ),
      ),
    );
  }
}
