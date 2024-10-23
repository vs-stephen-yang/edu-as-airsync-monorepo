import 'dart:io';

import 'package:android_window/main.dart' as android_window;
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AnnotationModel extends ChangeNotifier{

  SourceType? presentSourceType;

  DesktopCapturerSource? selectedSource;

  int _screenIndex = 0;

  int get screenIndex => _screenIndex;

  // 設定annotation顯示於哪個螢幕
  void setScreenIndex(String name) {
    RegExp regExp = RegExp(r'\d+');
    Match? match = regExp.firstMatch(name);
    if (match != null) {
      int index = int.tryParse(match.group(0)!) ?? 0;
      int result = (index - 1) < 0 ? 0 : (index - 1);
      _screenIndex = result;
    } else {
      _screenIndex = 0;
    }
  }

  static closeAnnotation() async {
    if (Platform.isWindows || Platform.isMacOS) {
      DesktopMultiWindow.getAllSubWindowIds().then(
        (subWindowIds) {
          for (final windowId in subWindowIds) {
            WindowController.fromWindowId(windowId).close();
          }
        },
      );
    } else if (Platform.isAndroid) {
      android_window.close();
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
