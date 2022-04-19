import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef WebRTCNativeViewCreatedCallback = void Function(
    WebRTCNativeViewController webRTCNativeViewController);

class WebRTCNativeView extends StatefulWidget {
  const WebRTCNativeView(
      {Key? key, required this.onWebRTCNativeViewCreatedCallback})
      : super(key: key);

  final WebRTCNativeViewCreatedCallback onWebRTCNativeViewCreatedCallback;

  @override
  State<StatefulWidget> createState() => _WebRTCNativeViewState();
}

class _WebRTCNativeViewState extends State<WebRTCNativeView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.mvbcast.crosswalk/webrtc_native_view',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the webrtc_native_view plugin');
  }

  void _onPlatformViewCreated(int id) {
    widget.onWebRTCNativeViewCreatedCallback(WebRTCNativeViewController._(id));
  }
}

class WebRTCNativeViewController {
  final MethodChannel channel;

  WebRTCNativeViewController._(int id)
      : channel = MethodChannel("com.mvbcast.crosswalk/webrtc_native_view_$id");
}
