import 'dart:io';

import 'package:flutter/material.dart';

class V3Background extends StatelessWidget {
  const V3Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: (Platform.isAndroid || Platform.isIOS)
          ? const SizedBox.shrink()
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  excludeFromSemantics: true,
                  'assets/images/ic_wallpaper.png',
                  width: 1280,
                ),
              ],
            ),
    );
  }
}
