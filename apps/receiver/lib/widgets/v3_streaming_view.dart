import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/screens/v3_quick_connect_menu.dart';
import 'package:display_flutter/screens/v3_shortcuts_menu.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/v3_streaming_function.dart';
import 'package:display_flutter/widgets/webrtc_view_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3StreamingView extends StatefulWidget {
  const V3StreamingView({super.key});

  @override
  State<StatefulWidget> createState() => _V3StreamingViewState();
}

class _V3StreamingViewState extends State<V3StreamingView> {
  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;
  final isAnnotationImplement = false; // todo: annotation

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    return Stack(
      children: [
        ValueListenableBuilder(
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
                            if (HybridConnectionList()
                                .isPresenting(index: index))
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
        ),
        Positioned(
          left: 13,
          bottom: 8,
          child: SizedBox(
            width: 41,
            child: IconButton(
              icon: const Image(
                image: Svg('assets/images/ic_streaming_shortcut.svg'),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _showShortcutsMenuDialog();
              },
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: isAnnotationImplement ? 96 : 41,
              height: 41,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3C455D),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isAnnotationImplement)
                    SizedBox(
                      width: 27,
                      child: IconButton(
                        icon: const Image(
                          image: Svg('assets/images/ic_streaming_pen.svg'),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // todo: annotation
                        },
                      ),
                    ),
                  if (isAnnotationImplement)
                    Container(
                      width: 1,
                      height: 21,
                      color: const Color(0xFF838CA6),
                    ),
                  SizedBox(
                    width: 27,
                    child: IconButton(
                      icon: const Image(
                        image: Svg('assets/images/ic_qrcode.svg'),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showQuickConnectMenuDialog();
                      },
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

  _showShortcutsMenuDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3ShortcutsMenu();
      },
    );
  }

  _showQuickConnectMenuDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3QuickConnectMenu();
      },
    );
  }
}
