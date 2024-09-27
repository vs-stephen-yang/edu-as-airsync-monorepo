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
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Image.asset(
                'assets/images/ic_logo_viewsonic_mobile.png',
                width: 170,
                height: 50,
              ),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  'assets/images/ic_wallpaper.png',
                  width: 1280,
                ),
                Positioned(
                  right: 24,
                  bottom: 16,
                  child: Image.asset(
                    'assets/images/ic_logo_viewsonic.png',
                    width: 225,
                    height: 70,
                  ),
                ),
              ],
            ),
    );
  }
}
