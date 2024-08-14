import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/v3_quick_connect_menu.dart';
import 'package:display_flutter/screens/v3_shortcuts_menu.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_participants_menu.dart';
import 'package:display_flutter/widgets/v3_streaming_function.dart';
import 'package:display_flutter/widgets/v3_webrtc_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3StreamingView extends StatefulWidget {
  const V3StreamingView({super.key});

  @override
  State<StatefulWidget> createState() => _V3StreamingViewState();
}

class _V3StreamingViewState extends State<V3StreamingView> {
  double _fullWidth = 0,
      _fullHeight = 0,
      _halfWidth = 0,
      _halfHeight = 0,
      _thirdWidth = 0;
  final isAnnotationImplement = false; // todo: annotation
  final isDeviceListImplement = false; // todo: device list
  final isDeviceListMenuOnScreen = false; // todo: device list menu

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    _thirdWidth = size.width / 3;
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: HybridConnectionList.hybridSplitScreenCount,
          builder: (context, int splitScreenCount, child) {
            if (splitScreenCount == 3 || splitScreenCount == 5) {
              // add one more to show "Waiting for others to join".
              splitScreenCount++;
            }
            return Stack(
              children: [
                Stack(
                  children: List.generate(splitScreenCount, (index) {
                    return ValueListenableBuilder(
                      valueListenable:
                          HybridConnectionList().enlargedScreenIndex,
                      builder: (context, enlargedIndex, child) {
                        double? left, top, right, bottom;
                        if (enlargedIndex != null) {
                          // enlarged screen
                          left = 0;
                          top = 0;
                        } else {
                          // no enlarged screen
                          if (splitScreenCount <= 2) {
                            // index 0: left (default)
                            // index 1: right
                            if (index == 1) {
                              right = 0;
                              top = 0;
                            } else {
                              left = 0;
                              top = 0;
                            }
                          } else if (splitScreenCount <= 4) {
                            // index 0: left-top (default)
                            // index 1: right-top
                            // index 2: left-bottom
                            // index 3: right-bottom
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
                              left = 0;
                              top = 0;
                            }
                          } else if (splitScreenCount <= 6) {
                            // index 0: left-top  (default)
                            // index 1: middle-top
                            // index 2: right-top
                            // index 3: left-bottom
                            // index 4: middle-bottom
                            // index 5: right-bottom
                            if (index == 1) {
                              left = _thirdWidth;
                              top = 0;
                            } else if (index == 2) {
                              right = 0;
                              top = 0;
                            } else if (index == 3) {
                              left = 0;
                              bottom = 0;
                            } else if (index == 4) {
                              left = _thirdWidth;
                              bottom = 0;
                            } else if (index == 5) {
                              right = 0;
                              bottom = 0;
                            } else {
                              left = 0;
                              top = 0;
                            }
                          } else {
                            left = 0;
                            top = 0;
                          }
                        }
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
                                if (HybridConnectionList()
                                    .isRTCConnector(index))
                                  V3WebrtcView(
                                      rtcConnector: HybridConnectionList()
                                          .getConnection<RTCConnector>(index),
                                      index: index),
                                if (HybridConnectionList()
                                    .isMirrorRequest(index))
                                  MirrorView(
                                      mirrorRequest: HybridConnectionList()
                                          .getConnection<MirrorRequest>(index)),
                                if (HybridConnectionList()
                                    .isPresenting(index: index))
                                  Positioned(
                                    bottom: 8,
                                    child: V3StreamingFunction(index: index),
                                  ),
                                if (HybridConnectionList()
                                    .isStopPresenting(index))
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 92,
                                        height: 80,
                                        child: Image(
                                          image: Svg(
                                              'assets/images/ic_split_screen_waiting.svg'),
                                        ),
                                      ),
                                      AutoSizeText(
                                        S.of(context).v3_waiting_join,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF3C455D),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                if (splitScreenCount == 1 &&
                    HybridConnectionList().isRTCConnector(0) &&
                    (HybridConnectionList().getConnection(0) as RTCConnector)
                            .presentationState ==
                        PresentationState.waitForStream)
                  const V3HeaderBar(isWaitForStream: true),
              ],
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
        Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
          return ChannelProvider.isModeratorMode || isDeviceListImplement
              ? Positioned(
                  right: 0,
                  bottom: 80,
                  child: SizedBox(
                    width: 41,
                    height: isDeviceListImplement ? 123 : 68,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: isDeviceListImplement ? 123 : 68,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 3,
                          child: SizedBox(
                            width: 27,
                            height: 27,
                            child: IconButton(
                              icon: const Image(
                                image: Svg(
                                    'assets/images/ic_streaming_moderator.svg'),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _showParticipantsMenuDialog();
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 9,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5D80ED),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            padding: EdgeInsets.zero,
                            child: const AutoSizeText(
                              '9',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (isDeviceListImplement)
                          Positioned(
                            top: 61,
                            right: 5,
                            child: Container(
                              width: 21,
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),
                        if (isDeviceListImplement)
                          Positioned(
                            right: 3,
                            bottom: 20,
                            child: SizedBox(
                              width: 27,
                              height: 27,
                              child: IconButton(
                                icon: Image(
                                  image: Svg(isDeviceListMenuOnScreen
                                      ? 'assets/images/ic_streaming_device_list_on.svg'
                                      : 'assets/images/ic_streaming_device_list_off.svg'),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  // todo: device list menu
                                },
                              ),
                            ),
                          ),
                        if (isDeviceListImplement)
                          Positioned(
                            left: 0,
                            top: 64,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5D80ED),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              padding: EdgeInsets.zero,
                              child: const AutoSizeText(
                                '1',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  double _getWidthHeight({
    required int index,
    required int splitScreenCount,
    required int? enlargedScreenIndex,
    required bool isWidth,
  }) {
    if (enlargedScreenIndex != null) {
      // enlarged screen
      if (enlargedScreenIndex == index) {
        return isWidth ? _fullWidth : _fullHeight;
      } else {
        return 0;
      }
    } else {
      // no enlarged screen
      if (splitScreenCount > 4) {
        return isWidth ? _thirdWidth : _halfHeight;
      } else if (splitScreenCount > 2) {
        return isWidth ? _halfWidth : _halfHeight;
      } else if (splitScreenCount > 1) {
        return isWidth ? _halfWidth : _fullHeight;
      } else {
        return isWidth ? _fullWidth : _fullHeight;
      }
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

  _showParticipantsMenuDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3ParticipantsMenu();
      },
    );
  }
}
