import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/toast.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/split_screen_function.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/tittle_bar.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:display_flutter/widgets/webrtc_view_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static ValueNotifier<bool> showTitleBottomBar = ValueNotifier(true);
  static ValueNotifier<int?> enlargedScreenPositionIndex = ValueNotifier(null);
  static ValueNotifier<bool> isShowDisplayCode = ValueNotifier(true);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;
  static const _androidAppRetain =
      MethodChannel('com.mvbcast.crosswalk/android_app_retain');
  List<BuildContext> pinDialogContextList = [];
  List<BuildContext> authDialogContextList = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    AppOverlayTab().setupOverlayTabHandler(context);
    Provider.of<ChannelProvider>(context, listen: false).startChannelProvider();
    Provider.of<MirrorStateProvider>(context, listen: false)
        .startMirrorStartProvider();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log.info('AppLifecycleState: $state');
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      channelProvider.updateAllAudioEnableState(false);
      mirrorStateProvider.updateAllAudioEnableState(false);
    } else if (state == AppLifecycleState.resumed) {
      channelProvider.updateAllAudioEnableState(true);
      mirrorStateProvider.updateAllAudioEnableState(true);
    }
  }

  Widget _buildDisplayGroupVideoView(ChannelProvider channelProvider) {
    final videoView = channelProvider.displayGroupVideoView;

    if (!channelProvider.isDisplayGroupVideoAvailable || videoView == null) {
      return const SizedBox.shrink();
    }

    return RTCVideoView(
      videoView.renderer,
      key: videoView.widgetKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    return PopScope(
      canPop: Platform.isAndroid ? false : true,
      onPopInvoked: (didPop) async {
        log.info('PopScope didPop: $didPop');
        if (didPop) {
          return;
        }
        try {
          _showSnackBarMessage(S.of(context).main_status_go_background);
          await Future.delayed(const Duration(seconds: 1));
          await _androidAppRetain.invokeMethod('sendToBackground');
        } catch (e, stackTrace) {
          log.severe('sendTiBackground', e, stackTrace);
        }
      },
      child: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: HybridConnectionList.hybridSplitScreenCount,
                builder: (context, int value, child) {
                  return Stack(
                    children: List.generate(value, (index) {
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
                        valueListenable: Home.enlargedScreenPositionIndex,
                        builder: (context, value, child) {
                          return Positioned(
                            left: left,
                            top: top,
                            right: right,
                            bottom: bottom,
                            child: SizedBox(
                              width: _getWidthHeight(index, true),
                              height: _getWidthHeight(index, false),
                              child: Stack(
                                children: <Widget>[
                                  if (HybridConnectionList()
                                      .isRTCConnector(index))
                                    WebRTCView(
                                        rtcConnector: HybridConnectionList()
                                            .getConnection<RTCConnector>(index),
                                        index: index),
                                  if (HybridConnectionList()
                                      .isMirrorRequest(index))
                                    MirrorView(
                                        mirrorRequest: HybridConnectionList()
                                            .getConnection<MirrorRequest>(
                                                index),
                                        fullWidth: _fullWidth,
                                        fullHeight: _fullHeight,
                                        displaySmartScalingEnabled: false,
                                        ),
                                  if (HybridConnectionList()
                                      .isPresenting(index: index))
                                    SplitScreenFunction(
                                      index: index,
                                      updateSize: () =>
                                          _handleSizeForSelected(index),
                                      onClose: () => _handleClose(index),
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
              ValueListenableBuilder(
                valueListenable: Home.showTitleBottomBar,
                builder: (BuildContext context, bool value, Widget? child) {
                  return value
                      ? Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            const Positioned(
                                left: 0, top: 0, right: 0, child: TitleBar()),
                            const Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: BottomBar()),
                            if (AppInstanceCreate().isInstalledInVBS100 |
                                AppInstanceCreate().isInstalledInVBS200)
                              const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: VbsOTA()),
                          ],
                        )
                      : const SizedBox.shrink();
                },
              ),
              ValueListenableBuilder(
                valueListenable: Home.isShowDisplayCode,
                builder: (BuildContext context, bool value, child) {
                  if (value) {
                    return const MainInfo();
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              // const MirrorView(),
              const Positioned(
                child: StatusBar(),
              ),
              const Positioned(
                left: 20,
                bottom: 0,
                child: StreamFunction(),
              ),
              Consumer<ChannelProvider>(builder: (context, provider, child) {
                return _buildDisplayGroupVideoView(provider);
              }),
              Consumer<MirrorStateProvider>(
                  builder: (_, mirrorStateProvider, __) {
                if (mirrorStateProvider.pinCode.isNotEmpty &&
                    pinDialogContextList.isEmpty) {
                  Future.delayed(Duration.zero, () {
                    _showPinCodeDialog(context);
                  });
                } else if (pinDialogContextList.isNotEmpty &&
                    mirrorStateProvider.pinCode.isEmpty) {
                  if (pinDialogContextList.isNotEmpty) {
                    for (var context in pinDialogContextList) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    }
                  }
                  pinDialogContextList.clear();
                }

                var mirrorRequestIdles = HybridConnectionList()
                    .getMirrorMap()
                    .values
                    .where(
                        (request) => request.mirrorState == MirrorState.idle);

                if (mirrorRequestIdles.isNotEmpty &&
                    authDialogContextList.isEmpty) {
                  for (MirrorRequest request
                      in HybridConnectionList().getMirrorMap().values) {
                    if (request.mirrorState == MirrorState.idle) {
                      if (HybridConnectionList.hybridSplitScreenCount.value <
                          HybridConnectionList.maxHybridSplitScreen) {
                        Future.delayed(Duration.zero, () {
                          if (mirrorStateProvider.isMirrorConfirmation) {
                            _showAuthDialog(context);
                          } else {
                            mirrorStateProvider
                                .setAcceptMirrorId(request.mirrorId);
                          }
                        });
                      } else {
                        mirrorStateProvider
                            .stopAcceptedMirror(request.mirrorId);
                        Future.delayed(Duration.zero, () {
                          _showMaxAmountToast();
                        });
                      }
                    }
                  }
                } else if (authDialogContextList.isNotEmpty &&
                    mirrorRequestIdles.isEmpty) {
                  if (authDialogContextList.isNotEmpty) {
                    for (var context in authDialogContextList) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    }
                  }
                  authDialogContextList.clear();
                }
                return const SizedBox.shrink();
              }),
              ValueListenableBuilder(
                  valueListenable: ChannelProvider.showReconnectWarnToast,
                  builder: (BuildContext context, bool value, Widget? child) {
                    if (value) {
                      for (RTCConnector connector in HybridConnectionList()
                          .getRtcConnectorMap()
                          .values) {
                        if (connector.reconnectChannelState ==
                                ReconnectState.fail &&
                            connector.presentationState ==
                                PresentationState.stopStreaming) {
                          Provider.of<ChannelProvider>(context, listen: false);
                          if (ChannelProvider.isModeratorMode) {
                            Future.delayed(Duration.zero, () {
                              Toast.makeReconnectToast(
                                connector.reconnectChannelState,
                                '${connector.senderNameWithEllipsis} ${S.of(context).main_feature_no_network_warning}',
                              )?.show(context);
                              ChannelProvider.showReconnectWarnToast.value =
                                  false;
                            });
                          }
                        }
                      }
                    }
                    return Container();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSizeForSelected(int index) {
    if (HybridConnectionList().isMirrorRequest(index)) {
      var connection =
          HybridConnectionList().getConnection<MirrorRequest>(index);
      if (connection.mirrorState == MirrorState.mirroring) {
        _updateSizeForSelected(index);
        return;
      }
    }

    _updateSizeForSelected(index);
  }

  void _handleClose(int index) {
    if (HybridConnectionList().isMirrorRequest(index)) {
      var connection =
          HybridConnectionList().getConnection<MirrorRequest>(index);
      if (connection.mirrorState == MirrorState.mirroring) {
        HybridConnectionList().stopPresenterBy(index);
        return;
      }
    }

    if (ChannelProvider.isModeratorMode) {
      HybridConnectionList().stopPresenterBy(index);
    } else {
      SplitScreenFunction.isMenuOnList.value
          .fillRange(0, SplitScreenFunction.isMenuOnList.value.length, false);
      HybridConnectionList().removePresenterBy(index);
    }
  }

  _showMaxAmountToast() {
    MotionToast(
      primaryColor: Colors.grey,
      description: Center(
        child: AutoSizeText(
          S.of(context).toast_maximum_split_screen,
          maxLines: 1,
        ),
      ),
      displaySideBar: false,
      position: MotionToastPosition.center,
    ).show(context);
  }

  _showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  _updateSizeForSelected(int selection) {
    if (selection == Home.enlargedScreenPositionIndex.value) {
      Home.enlargedScreenPositionIndex.value = null;
    } else {
      Home.enlargedScreenPositionIndex.value = selection;
    }
    HybridConnectionList().setSpecifiedSplitScreenWindowQuality(
        selection, Home.enlargedScreenPositionIndex.value == selection);
  }

  double _getWidthHeight(int index, bool isWidth) {
    if (Home.enlargedScreenPositionIndex.value == index) {
      // enlarged screen
      return isWidth ? _fullWidth : _fullHeight;
    } else if (Home.enlargedScreenPositionIndex.value != null) {
      // one of the screens is enlarged
      return 0;
    } else {
      // no enlarged screen
      if (HybridConnectionList.hybridSplitScreenCount.value == 1) {
        return isWidth ? _fullWidth : _fullHeight;
      }
      return isWidth ? _halfWidth : _halfHeight;
    }
  }

  _showPinCodeDialog(BuildContext context) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        pinDialogContextList.add(dialogContext);
        return Consumer<MirrorStateProvider>(
          builder: (_, mirrorStateProvider, __) {
            return PopScope(
              // Using onWillPop to block back key return,
              // it will break "Show PinCode mechanism"
              canPop: false,
              child: Dialog(
                backgroundColor: Colors.transparent,
                alignment: Alignment.bottomRight,
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.airplay),
                                Text(
                                  S.of(context).main_airplay_pin_code,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              mirrorStateProvider.pinCode,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: FocusIconButton(
                          icons: Icons.cancel_outlined,
                          iconForegroundColor: Colors.white,
                          hasFocusSize: AppUIConstant.iconHasFocusSize,
                          notFocusSize: AppUIConstant.iconNotFocusSize,
                          onClick: () {
                            if (pinDialogContextList.isNotEmpty) {
                              for (var context in pinDialogContextList) {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              }
                              pinDialogContextList.clear();
                            }
                            mirrorStateProvider.clearPinCode();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  _showAuthDialog(BuildContext context) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        authDialogContextList.add(dialogContext);
        return Consumer<MirrorStateProvider>(
          builder: (_, mirrorStateProvider, __) {
            var width = MediaQuery.of(context).size.width / 3;
            var height = MediaQuery.of(context).size.height / 4;
            var mirrorRequestIdles = HybridConnectionList()
                .getMirrorMap()
                .values
                .where((request) => request.mirrorState == MirrorState.idle);
            double minHeight =
                min((mirrorRequestIdles.length * height).toDouble(), 500.0);
            return PopScope(
              // Using onWillPop to block back key return,
              // it will break "Show Prompt mechanism"
              canPop: false,
              child: Dialog(
                backgroundColor: Colors.transparent,
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: width,
                  height: minHeight,
                  child: ListView.separated(
                    reverse: HybridConnectionList().isMirroring(),
                    itemCount: mirrorRequestIdles.length,
                    itemBuilder: (BuildContext buildContext, int index) {
                      return Container(
                        width: width,
                        height: height,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sprintf(S.current.main_mirror_from_client, [
                                mirrorRequestIdles.toList()[index].mirrorId
                              ]),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const Spacer(),
                            Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              children: <Widget>[
                                FocusElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.white,
                                  ),
                                  hasFocusWidth: 110,
                                  notFocusWidth: 100,
                                  hasFocusHeight: 30,
                                  notFocusHeight: 25,
                                  onClick: () {
                                    var mirrorId = mirrorRequestIdles
                                        .toList()[index]
                                        .mirrorId;
                                    mirrorStateProvider
                                        .clearRequestMirrorId(mirrorId);
                                  },
                                  child: AutoSizeText(
                                    S.of(context).main_mirror_prompt_cancel,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                FocusElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    backgroundColor: Colors.blue,
                                  ),
                                  hasFocusWidth: 110,
                                  notFocusWidth: 100,
                                  hasFocusHeight: 30,
                                  notFocusHeight: 25,
                                  onClick: () async {
                                    String? mirrorId = mirrorRequestIdles
                                        .toList()[index]
                                        .mirrorId;
                                    mirrorStateProvider
                                        .setAcceptMirrorId(mirrorId);
                                  },
                                  child: AutoSizeText(
                                    S.of(context).main_mirror_prompt_accept,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext buildContext, int index) {
                      return const SizedBox(
                        height: 5,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
