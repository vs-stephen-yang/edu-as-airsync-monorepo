import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:display_flutter/screens/v3_new_sharing_menu.dart';
import 'package:display_flutter/screens/v3_quick_connect_menu.dart';
import 'package:display_flutter/screens/v3_shortcuts_menu.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_streaming_function.dart';
import 'package:display_flutter/widgets/v3_webrtc_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart' as provider;

class V3StreamingView extends ConsumerStatefulWidget {
  const V3StreamingView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _V3StreamingViewState();
}

class _V3StreamingViewState extends ConsumerState {
  double _fullWidth = 0,
      _fullHeight = 0,
      _halfWidth = 0,
      _halfHeight = 0,
      _thirdWidth = 0;
  bool _isNewSharingOnScreen = false;
  final isAnnotationImplement = false; // todo: annotation

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
            if (splitScreenCount >= 0) {
              final toggle = ref.read(groupProvider).broadcastToGroup;
              final launchType =
                  ref.read(groupProvider).broadcastGroupLaunchType;
              if (toggle &&
                  launchType == BroadcastGroupLaunchType.onlyWhenCasting) {
                final List<GroupListItem> selectedList = splitScreenCount > 0
                    ? ref.read(groupProvider).selectedList
                    : [];
                provider.Provider.of<ChannelProvider>(context, listen: false)
                    .startDisplayGroup(selectedList);
              }
            }
            if (splitScreenCount == 3 || splitScreenCount == 5) {
              // add one more to show "Waiting for others to join".
              splitScreenCount++;
            }
            if (V3Home.isShowSettingsMenu.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                V3Home.isShowSettingsMenu.value = false;
              });
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
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: context.tokens.color
                                              .vsdslColorSurface800,
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
            height: 41,
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
                color: context.tokens.color.vsdslColorSurface800,
                borderRadius: context.tokens.radii.vsdslRadiusFull,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isAnnotationImplement)
                    SizedBox(
                      width: 41,
                      height: 41,
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
                      color: context.tokens.color.vsdslColorOnSurfaceVariant,
                    ),
                  SizedBox(
                    width: 41,
                    height: 41,
                    child: IconButton(
                      icon: const Image(
                        image: Svg('assets/images/ic_streaming_qrcode.svg'),
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
        ValueListenableBuilder(
          valueListenable:
              provider.Provider.of<ChannelProvider>(context, listen: false)
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
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3ShortcutsMenu();
      },
    );
  }

  _showQuickConnectMenuDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3QuickConnectMenu();
      },
    );
  }

  _showNewSharingMessageDialog(List<String> names) async {
    String name = names.first;
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        _isNewSharingOnScreen = true;
        return V3NewSharingMenu(name: name);
      },
    ).then((_) {
      ChannelProvider channelProvider =
          provider.Provider.of<ChannelProvider>(context, listen: false);
      channelProvider.showNewSharingNameList.value.remove(name);
      channelProvider.showNewSharingNameList.value =
          List.from(channelProvider.showNewSharingNameList.value);
      _isNewSharingOnScreen = false;
    });
  }
}
