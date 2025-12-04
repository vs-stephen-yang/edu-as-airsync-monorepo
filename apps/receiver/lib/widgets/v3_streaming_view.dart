import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:display_flutter/screens/v3_new_sharing_menu.dart';
import 'package:display_flutter/utility/navigation_service_util.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/v3_bluetooth_touchback_status_notification.dart';
import 'package:display_flutter/widgets/v3_casting_view_focus_traversal_policy.dart';
import 'package:display_flutter/widgets/v3_extend_casting_time_menu.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_streaming_expandable.dart';
import 'package:display_flutter/widgets/v3_streaming_function.dart';
import 'package:display_flutter/widgets/v3_webrtc_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

@Deprecated('Use NewWidget instead')
class V3StreamingView extends StatefulWidget {
  const V3StreamingView({super.key});

  @override
  State<StatefulWidget> createState() => _V3StreamingViewState();
}

class _V3StreamingViewState extends State {
  double _fullWidth = 0,
      _fullHeight = 0,
      _halfWidth = 0,
      _halfHeight = 0,
      _thirdWidth = 0,
      _thirdHeight = 0;
  bool _isNewSharingOnScreen = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    _thirdWidth = size.width / 3;
    _thirdHeight = size.height / 3;
    return FocusTraversalGroup(
      policy: CastingViewFocusTraversalPolicy(),
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: HybridConnectionList.hybridSplitScreenCount,
            builder: (context, int splitScreenCount, child) {
              // 當有任何 cast 進入，則關閉 setting menu
              if (splitScreenCount > 0) {
                navService.dismissRegisteredDialogs();
              }

              if (splitScreenCount >= 0) {
                Provider.of<ChannelProvider>(context, listen: false)
                    .refreshOnlyWhenCastingStatus();
              }

              if (splitScreenCount == 7) {
                // add two more to show "Waiting for others to join".
                splitScreenCount += 2;
              } else if (splitScreenCount == 3 ||
                  splitScreenCount == 5 ||
                  splitScreenCount == 8) {
                // add one more to show "Waiting for others to join".
                splitScreenCount++;
              }
              // 沒影任何投影時，關閉資訊dialog
              if (navService.canPop() &&
                  HybridConnectionList.hybridSplitScreenCount.value == 0) {
                navService.goBack();
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
                            } else if (splitScreenCount <= 9) {
                              // index 0: left-top  (default)
                              // index 1: middle-top
                              // index 2: right-top
                              // index 3: left-middle
                              // index 4: middle-middle
                              // index 5: right-middle
                              // index 6: left-bottom
                              // index 7: middle-bottom
                              // index 8: right-bottom
                              if (index == 1) {
                                left = _thirdWidth;
                                top = 0;
                              } else if (index == 2) {
                                right = 0;
                                top = 0;
                              } else if (index == 3) {
                                left = 0;
                                top = _thirdHeight;
                              } else if (index == 4) {
                                left = _thirdWidth;
                                top = _thirdHeight;
                              } else if (index == 5) {
                                right = 0;
                                top = _thirdHeight;
                              } else if (index == 6) {
                                left = 0;
                                bottom = 0;
                              } else if (index == 7) {
                                left = _thirdWidth;
                                bottom = 0;
                              } else if (index == 8) {
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

                          bool smartScalingDecision = false;
                          if (Provider.of<ChannelProvider>(context)
                                  .smartScaling &&
                              (splitScreenCount == 1 ||
                                  (splitScreenCount > 1 &&
                                      enlargedIndex != null))) {
                            smartScalingDecision = true;
                          }

                          final viewportWidth = _getWidthHeight(
                              index: index,
                              splitScreenCount: splitScreenCount,
                              enlargedScreenIndex: enlargedIndex,
                              isWidth: true);

                          return Positioned(
                            left: left,
                            top: top,
                            right: right,
                            bottom: bottom,
                            child: SizedBox(
                              width: viewportWidth,
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
                                        index: index,
                                        screenWidth: _fullWidth,
                                        screenHeight: _fullHeight,
                                        displaySmartScalingEnabled:
                                            smartScalingDecision),
                                  if (HybridConnectionList()
                                      .isMirrorRequest(index))
                                    MirrorView(
                                        mirrorRequest: HybridConnectionList()
                                            .getConnection<MirrorRequest>(
                                                index),
                                        screenWidth: _fullWidth,
                                        screenHeight: _fullHeight,
                                        displaySmartScalingEnabled:
                                            smartScalingDecision),
                                  Consumer<ChannelProvider>(
                                    builder: (_, channelProvider, __) {
                                      // 直接監聽ChannelProvider確保每次都能抓到最新的狀態
                                      if (HybridConnectionList()
                                          .isPresenting(index: index)) {
                                        return Positioned(
                                          bottom: 0,
                                          child: V3StreamingFunction(
                                            index: index,
                                            availableWidth: viewportWidth,
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  if (HybridConnectionList()
                                      .isStopPresenting(index))
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ExcludeSemantics(
                                          child: SvgPicture.asset(
                                            'assets/images/ic_split_screen_waiting.svg',
                                            width: 92,
                                            height: 80,
                                          ),
                                        ),
                                        AutoSizeText(
                                          S.of(context).v3_waiting_join,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: context.tokens.color
                                                .vsdslColorOnSurfaceInverse,
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
                    Positioned(child: const V3HeaderBar(isWaitForStream: true)),
                ],
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: V3Home.isShowHeaderFooterBar,
            builder: (context, value, child) {
              return value
                  ? const SizedBox.shrink()
                  : const Positioned(
                      left: 13,
                      bottom: 8,
                      child: ExpandableWidget(),
                    );
            },
          ),
          ValueListenableBuilder(
            valueListenable:
                Provider.of<ChannelProvider>(context, listen: false)
                    .showNewSharingNameList,
            builder: (_, value, __) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (value.isNotEmpty &&
                    HybridConnectionList.hybridSplitScreenCount.value > 0) {
                  if (!_isNewSharingOnScreen) {
                    _showNewSharingMessageDialog(value);
                  }
                }
              });
              return const SizedBox.shrink();
            },
          ),
          Positioned(
            bottom: _isNewSharingOnScreen ? 164 : 54,
            right: 53,
            child: const V3ExtendCastingTimeMenu(),
          ),
          Positioned(
            bottom: _isNewSharingOnScreen ? 164 : 54,
            right: 53,
            child: const V3BluetoothStatusNotification(),
          ),
        ],
      ),
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
      if (splitScreenCount > 6) {
        return isWidth ? _thirdWidth : _thirdHeight;
      } else if (splitScreenCount > 4) {
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

  _showNewSharingMessageDialog(List<String> names) async {
    String name = names.first;
    if (!mounted) return;
    setState(() {
      _isNewSharingOnScreen = true;
    });
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return V3NewSharingMenu(name: name);
      },
    ).then((_) {
      if (mounted) {
        ChannelProvider channelProvider =
            Provider.of<ChannelProvider>(context, listen: false);
        channelProvider.showNewSharingNameList.value.remove(name);
        channelProvider.showNewSharingNameList.value =
            List.from(channelProvider.showNewSharingNameList.value);
      }
    }).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _isNewSharingOnScreen = false;
      });
    });
  }
}