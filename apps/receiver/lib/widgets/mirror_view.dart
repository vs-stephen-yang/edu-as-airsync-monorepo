import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MirrorView extends StatefulWidget {
  const MirrorView({super.key, required this.mirrorRequest, this.screenWidth = 0.0, this.screenHeight = 0.0, this.displaySmartScalingEnabled = false});

  final MirrorRequest mirrorRequest;
  final double screenWidth;
  final double screenHeight;
  final bool displaySmartScalingEnabled;

  @override
  State<StatefulWidget> createState() => MirrorViewState();
}

class MirrorViewState extends State<MirrorView> {
  GlobalKey mirrorViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<MirrorStateProvider>(
      builder: (context, mirror, child) {
        double castRatio = widget.mirrorRequest.aspectRatio;
        if (widget.displaySmartScalingEnabled && widget.screenHeight != 0) {
          double screenRatio = widget.screenWidth / widget.screenHeight;

          // check video frame and device orientation
          bool isVideoLandscape = widget.mirrorRequest.aspectRatio >= 1.0;
          bool isDeviceLandscape = (widget.screenWidth > widget.screenHeight);
          if (isVideoLandscape == isDeviceLandscape) {
            castRatio = screenRatio;
          }
        }
        return ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            children: [
              if (widget.mirrorRequest.mirrorState == MirrorState.mirroring)
                Container(
                  color: Colors.black,
                  child: Center(
                    child: NotificationListener<SizeChangedLayoutNotification>(
                      onNotification: (notification) {
                        mirror.onWidgetSizeChanged();
                        return true;
                      },
                      child: SizeChangedLayoutNotifier(
                        child: Listener(
                          onPointerDown: (PointerDownEvent event) {
                            mirror.onTouchEvent(event,
                                widget.mirrorRequest.mirrorId, mirrorViewKey);
                          },
                          onPointerMove: (PointerMoveEvent event) {
                            mirror.onTouchEvent(event,
                                widget.mirrorRequest.mirrorId, mirrorViewKey);
                          },
                          onPointerUp: (PointerUpEvent event) {
                            mirror.onTouchEvent(event,
                                widget.mirrorRequest.mirrorId, mirrorViewKey);
                          },
                          child: AspectRatio(
                            key: mirrorViewKey,
                            aspectRatio: castRatio,
                            child: Texture(
                                textureId: widget.mirrorRequest.textureId),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
