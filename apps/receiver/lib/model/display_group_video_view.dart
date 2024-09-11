import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DisplayGroupVideoView {
  RTCVideoRenderer renderer;
  GlobalKey widgetKey;

  DisplayGroupVideoView(this.renderer, this.widgetKey);
}
