import 'dart:io';

import 'package:display_cast_flutter/screens/debug_switch.dart';
import 'package:flutter/material.dart';

class V3Background extends StatelessWidget {
  const V3Background({super.key});

  final int openDebugCounter = 5;

  @override
  Widget build(BuildContext context) {
    int debugCounter = 0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: (Platform.isAndroid || Platform.isIOS)
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: GestureDetector(
                onTap: () {
                  debugCounter++;
                  if (debugCounter == openDebugCounter) {
                    _showMenuDialog(context, const DebugSwitch());
                    debugCounter = 0;
                  }
                },
                child: ExcludeSemantics(
                  child: Image.asset(
                    'assets/images/ic_logo_viewsonic_mobile.png',
                    width: 170,
                    height: 50,
                  ),
                ),
              ),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ExcludeSemantics(
                  child: Image.asset(
                    'assets/images/ic_wallpaper.png',
                    width: 1280,
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: () {
                      debugCounter++;
                      if (debugCounter == openDebugCounter) {
                        _showMenuDialog(context, const DebugSwitch());
                        debugCounter = 0;
                      }
                    },
                    child: ExcludeSemantics(
                      child: Image.asset(
                        'assets/images/ic_logo_viewsonic_desktop.png',
                        width: 193,
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  _showMenuDialog(BuildContext context, Widget widget) async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return widget;
      },
    );
  }
}
