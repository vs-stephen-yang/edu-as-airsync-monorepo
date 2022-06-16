import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/webrtc_info.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

typedef WebRTCNativeViewCreatedCallback = void Function(
    WebRTCNativeViewController webRTCNativeViewController);

class WebRTCNativeView extends StatefulWidget {
  const WebRTCNativeView(
      {Key? key,
      required this.useHybrid,
      required this.onWebRTCNativeViewCreatedCallback})
      : super(key: key);

  final bool useHybrid;
  final WebRTCNativeViewCreatedCallback onWebRTCNativeViewCreatedCallback;

  @override
  State createState() => WebRTCNativeViewState();
}

class WebRTCNativeViewState extends State<WebRTCNativeView>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool showConnectionInfo = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'com.mvbcast.crosswalk/webrtc_native_view';
    Widget nativeView;
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (widget.useHybrid) {
        nativeView = PlatformViewLink(
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
              widget.onWebRTCNativeViewCreatedCallback(
                  WebRTCNativeViewController(this, id));
            });
            viewController.create();
            return viewController;
          },
        );
      } else {
        nativeView = AndroidView(
          viewType: viewType,
          onPlatformViewCreated: (id) {
            widget.onWebRTCNativeViewCreatedCallback(
                WebRTCNativeViewController(this, id));
          },
        );
      }
    } else {
      nativeView = Text(
          '$defaultTargetPlatform is not yet supported by the webrtc_native_view plugin');
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        nativeView,
        Visibility(
          visible: showConnectionInfo,
          child: Transform.scale(
            scale: SplitScreen.splitScreenEnabled.value ? 0.5 : 1.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: WebRTCInfo.getInstance().moderatorMode,
                    child: Column(
                      children: <Widget>[
                        Text(
                          S.of(context).main_wait_up_next,
                          style: const TextStyle(
                            color: AppColors.primary_white,
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          WebRTCInfo.getInstance().presenterName,
                          style: const TextStyle(
                            color: AppColors.primary_blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: RotationTransition(
                      turns: _animation,
                      child: const Image(
                        image: Svg(
                          'assets/images/ic_loading.svg',
                          size: Size.square(32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '"Waiting for a sender to share a screen..."',
                    style: TextStyle(
                      color: AppColors.primary_blue,
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  switchConnectionState(bool state) {
    setState(() {
      showConnectionInfo = state;
    });
  }
}

class WebRTCNativeViewController {
  late WebRTCNativeViewState nativeViewState;
  late MethodChannel channel;

  WebRTCNativeViewController(WebRTCNativeViewState viewState, int id) {
    nativeViewState = viewState;
    channel = MethodChannel("com.mvbcast.crosswalk/webrtc_native_view_$id");
  }
}
