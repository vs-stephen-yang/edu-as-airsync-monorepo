
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VersionUtil {
  static bool get isOpenVersion {
    return WebRTC.platformIsMacOS && appFlavor == 'Open';
  }
}


