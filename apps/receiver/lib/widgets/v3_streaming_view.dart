import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/v3_streaming_function.dart';
import 'package:display_flutter/widgets/webrtc_view_new.dart';
import 'package:flutter/material.dart';

class V3StreamingView extends StatefulWidget {
  const V3StreamingView({super.key});

  @override
  State<StatefulWidget> createState() => _V3StreamingViewState();
}

class _V3StreamingViewState extends State<V3StreamingView> {
  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    return ValueListenableBuilder(
      valueListenable: HybridConnectionList.hybridSplitScreenCount,
      builder: (context, int splitScreenCount, child) {
        return Stack(
          children: List.generate(splitScreenCount, (index) {
            double? left, top, right, bottom;
            if (index == 1) {
              right = 0;
              top = 0;
            } else if (index == 2) {
              left = 0;
              bottom = 0;
            } else if (index == 3) {
              right = 0;
              bottom = 0;
            } else {
              // index 0 and default.
              left = 0;
              top = 0;
            }
            return ValueListenableBuilder(
              valueListenable: HybridConnectionList().enlargedScreenIndex,
              builder: (context, enlargedIndex, child) {
                return Positioned(
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom,
                  child: SizedBox(
                    width: _getWidthHeight(
                        index: index,
                        splitScreenCount: splitScreenCount,
                        enlargedScreenIndex: enlargedIndex,
                        isWidth: true),
                    height: _getWidthHeight(
                        index: index,
                        splitScreenCount: splitScreenCount,
                        enlargedScreenIndex: enlargedIndex,
                        isWidth: false),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        if (HybridConnectionList().isRTCConnector(index))
                          WebRTCView(
                              rtcConnector: HybridConnectionList()
                                  .getConnection<RTCConnector>(index),
                              index: index),
                        if (HybridConnectionList().isMirrorRequest(index))
                          MirrorView(
                              mirrorRequest: HybridConnectionList()
                                  .getConnection<MirrorRequest>(index)),
                        if (HybridConnectionList().isPresenting(index: index))
                          Positioned(
                            bottom: 8,
                            child: V3StreamingFunction(index: index),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  double _getWidthHeight({
    required int index,
    required int splitScreenCount,
    required int? enlargedScreenIndex,
    required bool isWidth,
  }) {
    if (enlargedScreenIndex == index) {
      // enlarged screen
      return isWidth ? _fullWidth : _fullHeight;
    } else if (enlargedScreenIndex != null) {
      // one of the screens is enlarged
      return 0;
    } else {
      // no enlarged screen
      if (splitScreenCount == 1) {
        return isWidth ? _fullWidth : _fullHeight;
      }
      return isWidth ? _halfWidth : _halfHeight;
    }
  }
}
