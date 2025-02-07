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
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_streaming_function.dart';
import 'package:display_flutter/widgets/v3_webrtc_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
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
                    .startDisplayGroup(selectedList,
                        anyCasting: splitScreenCount != 0);
              }
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
                                    bottom: 0,
                                    child: V3StreamingFunction(index: index),
                                  ),
                                if (HybridConnectionList()
                                    .isStopPresenting(index))
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_split_screen_waiting.svg',
                                        width: 92,
                                        height: 80,
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

class ExpandableWidget extends StatefulWidget {
  const ExpandableWidget({super.key});

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  bool isExpanded = false;
  bool isAnimating = false;
  bool _showQuickConnect = false;
  bool _showShortcut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // single icon row is -> 45, three icon row is -> 45x3 + Gap(8)x2 = 151
    _widthAnimation = Tween<double>(begin: 45.0, end: 151.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _widthAnimation.addStatusListener((AnimationStatus status) {
      isAnimating = status.isAnimating;
    });
  }

  void _toggle() {
    if (isAnimating) return;
    if (isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: SizedBox(
            width: _widthAnimation.value,
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                V3Focus(
                  child: Container(
                    width: 41,
                    height: 41,
                    padding: EdgeInsets.zero,
                    decoration: ShapeDecoration(
                      color: context.tokens.color.vsdslColorSurface800,
                      shape: const OvalBorder(),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        isExpanded
                            ? 'assets/images/ic_streaming_shortcut_minimize.svg'
                            : 'assets/images/ic_streaming_shortcut_expanded.svg',
                      ),
                      focusColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _toggle();
                      },
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const Gap(8),
                  V3Focus(
                    child: Container(
                      width: 41,
                      height: 41,
                      decoration: ShapeDecoration(
                        color: _showShortcut
                            ? context.tokens.color.vsdslColorSecondary
                            : context.tokens.color.vsdslColorSurface800,
                        shape: const OvalBorder(),
                      ),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/ic_streaming_shortcut.svg',
                        ),
                        focusColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showShortcutsMenuDialog();
                          });
                          setState(() {
                            _showShortcut = true;
                          });
                        },
                      ),
                    ),
                  ),
                  const Gap(8),
                  V3Focus(
                    child: Container(
                      width: 41,
                      height: 41,
                      decoration: ShapeDecoration(
                        color: _showQuickConnect
                            ? context.tokens.color.vsdslColorSecondary
                            : context.tokens.color.vsdslColorSurface800,
                        shape: const OvalBorder(),
                      ),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/ic_streaming_qrcode.svg',
                        ),
                        focusColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showQuickConnectMenuDialog();
                          });
                          setState(() {
                            _showQuickConnect = true;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  _showShortcutsMenuDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => FocusAwareBuilder(
          builder: (primaryFocusNode) =>
              V3ShortcutsMenu(primaryFocusNode: primaryFocusNode)),
    ).then((_) {
      setState(() {
        _showShortcut = false;
      });
    });
  }

  _showQuickConnectMenuDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => FocusAwareBuilder(
        builder: (primaryFocusNode) =>
            V3QuickConnectMenu(primaryFocusNode: primaryFocusNode),
      ),
    ).then((_) {
      setState(() {
        _showQuickConnect = false;
      });
    });
  }
}
