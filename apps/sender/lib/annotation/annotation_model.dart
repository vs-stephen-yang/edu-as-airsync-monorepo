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
}
