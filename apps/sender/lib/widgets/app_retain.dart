import 'dart:io';

import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// https://blog.csdn.net/weixin_46156477/article/details/116779831
///
class AppRetain extends StatelessWidget {
  const AppRetain({super.key, required this.child});

  static const _androidAppRetain =
      MethodChannel('com.viewsonic.display.cast/android_app_retain');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
            try {
              _showSnackBarMessage(
                context,
                'AirSync App goes to the background.',
              );
              await Future.delayed(const Duration(seconds: 1));
              _androidAppRetain.invokeMethod('sendToBackground');
              return Future.value(false);
            } catch (e) {
              debugModePrint(e);
              return Future.value(true);
            }
          }
        } else {
          return Future.value(true);
        }
      },
      child: child,
    );
  }

  _showSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
