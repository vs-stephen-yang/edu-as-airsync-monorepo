import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

typedef WebRTCNativeViewCreatedCallback = void Function(
    WebRTCNativeViewController webRTCNativeViewController);

class WebRTCNativeView extends StatelessWidget {
  const WebRTCNativeView(
      {Key? key,
      required this.useHybrid,
      required this.onWebRTCNativeViewCreatedCallback})
      : super(key: key);

  final bool useHybrid;
  final WebRTCNativeViewCreatedCallback onWebRTCNativeViewCreatedCallback;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'com.mvbcast.crosswalk/webrtc_native_view';
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (useHybrid) {
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory:
              (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <
                  Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            SurfaceAndroidViewController viewController =
                PlatformViewsService.initSurfaceAndroidView(
                    id: params.id,
                    viewType: viewType,
                    layoutDirection: TextDirection.ltr);
            viewController.addOnPlatformViewCreatedListener((id) {
              onWebRTCNativeViewCreatedCallback(
                  WebRTCNativeViewController._(id));
            });
            viewController.create();
            return viewController;
          },
        );
      } else {
        return AndroidView(
          viewType: viewType,
          onPlatformViewCreated: (id) {
            onWebRTCNativeViewCreatedCallback(WebRTCNativeViewController._(id));
          },
        );
      }
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the webrtc_native_view plugin');
  }
}

class WebRTCNativeViewController {
  final MethodChannel channel;

  WebRTCNativeViewController._(int id)
      : channel = MethodChannel("com.mvbcast.crosswalk/webrtc_native_view_$id");
}
