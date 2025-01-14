import 'dart:async';
import 'dart:io';

import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter/foundation.dart';
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
    return PopScope(
      canPop: (!kIsWeb && Platform.isAndroid) ? false : true,
      onPopInvoked: (didPop) async {
        log.info('PopScope didPop: $didPop');
        if (didPop) {
          return;
        }
        try {
          _showSnackBarMessage(
            context,
            'AirSync App goes to the background.',
          );
          await Future.delayed(const Duration(seconds: 1));
          unawaited(_androidAppRetain.invokeMethod('sendToBackground'));
        } catch (e, stackTrace) {
          log.severe('sendToBackground', e, stackTrace);
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
