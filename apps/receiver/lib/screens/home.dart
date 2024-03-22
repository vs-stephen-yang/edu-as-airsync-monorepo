import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/main_info_net.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/split_screen_function.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/tittle_bar.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:display_flutter/widgets/webrtc_view_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static ValueNotifier<bool> showTitleBottomBar = ValueNotifier(true);
  static ValueNotifier<int?> enlargedScreenPositionIndex = ValueNotifier(null);
  static ValueNotifier<bool> isShowDisplayCode = ValueNotifier(true);
  static ValueNotifier<bool> isShowAuthDialog = ValueNotifier(false);
  static ValueNotifier<bool> isShowPinDialog = ValueNotifier(false);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;
  static const _androidAppRetain =
      MethodChannel('com.mvbcast.crosswalk/android_app_retain');
  List<BuildContext> pinDialogContextList = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    AppOverlayTab().setupOverlayTabHandler(
        buildContext: context, isVisible: AppPreferences().showOverlayTab);

    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    // Duo to in the EULA menu state, may already got display code,
    // we need update device name with display code here
    // and add listener to update while display code changed.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateDeviceName(channelProvider);
    });
    channelProvider.addListener(() {
      _updateDeviceName(channelProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    printInDebug('AppLifecycleState: $state', type: runtimeType);
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      channelProvider.updateAllAudioEnableState(false);
      mirrorStateProvider.updateAudioEnable(false);
    } else if (state == AppLifecycleState.resumed) {
      channelProvider.updateAllAudioEnableState(true);
      mirrorStateProvider.updateAudioEnable(true);
    }
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
        printInDebug('PopScope didPop: $didPop', type: runtimeType);
        if (didPop) {
          return;
        }
        try {
          _showSnackBarMessage(S.of(context).main_status_go_background);
          await Future.delayed(const Duration(seconds: 1));
          _androidAppRetain.invokeMethod('sendToBackground');
        } catch (e) {
          printInDebug(e, type: runtimeType);
        }
      },
      child: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: SplitScreen.mapSplitScreen,
                builder: (context, Map<String, dynamic> value, child) {
                  return Stack(
                    children: List.generate(4, (index) {
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
                                    WebRTCView(index: index),
                                  if (HybridConnectionList()
                                      .isMirrorRequest(index))
                                    MirrorView(index: index),
                                  if (HybridConnectionList()
                                      .isPresenting(index: index))
                                    SplitScreenFunction(
                                      index: index,
                                      updateSize: () {
                                        _updateSizeForSelected(index);
                                      },
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
                  return Visibility(
                    visible: value,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        const Positioned(
                            left: 0, top: 0, right: 0, child: TitleBar()),
                        const Positioned(
                            left: 0, right: 0, bottom: 0, child: BottomBar()),
                        if (AppInstanceCreate().isInstalledInVBS100 |
                            AppInstanceCreate().isInstalledInVBS200)
                          const Positioned(
                              left: 0, right: 0, bottom: 0, child: VbsOTA()),
                      ],
                    ),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: Home.isShowDisplayCode,
                builder: (BuildContext context, bool value, child) {
                  if (value) {
                    return const MainInfoInternet();
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

              ValueListenableBuilder(
                  valueListenable: Home.isShowPinDialog,
                  builder: (BuildContext context, bool value, child) {
                    if (value) {
                      var mirror = context.read<MirrorStateProvider>();
                      if (mirror.pinCode != '') {
                        Future.delayed(Duration.zero, () {
                          _showPinCodeDialog(context, mirror);
                        });
                      }
                    } else {
                      if (pinDialogContextList.isNotEmpty) {
                        for (var context in pinDialogContextList) {
                          Navigator.pop(context);
                        }
                      }
                      pinDialogContextList.clear();
                    }
                    return const SizedBox.shrink();
                  }),

              ValueListenableBuilder(
                  valueListenable: Home.isShowAuthDialog,
                  builder: (BuildContext context, bool value, child) {
                    if (value) {
                      var mirror = context.read<MirrorStateProvider>();
                      var mirrorMap = HybridConnectionList().getMirrorMap();
                      for (MirrorRequest request in mirrorMap.values) {
                        if (request.mirrorState == MirrorState.idle) {
                          Future.delayed(Duration.zero, () {
                            _showAuthDialog(context, mirror);
                          });
                        }
                      }
                    }
                    return const SizedBox.shrink();
                  }),
            ],
          ),
        ),
      ),
    );
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
    context.read<ChannelProvider>().updateAllQuality(
        selection, Home.enlargedScreenPositionIndex.value == selection);
  }

  double _getWidthHeight(int index, bool isWidth) {
    if (Home.enlargedScreenPositionIndex.value == index) {
      // enlarged screen
      return isWidth ? _fullWidth : _fullHeight;
    } else if (Home.enlargedScreenPositionIndex.value != null) {
      // one of the screens is enlarged
      return 0; // MUST use 1 to create view, 0 won't.
    } else {
      // no enlarged screen
      if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] == 1) {
        // if (index ==
        //     SplitScreen.mapSplitScreen.value[keySplitScreenLastId]) {
        return isWidth ? _fullWidth : _fullHeight;
        // } else {
        //   return 0; // MUST use 1 to create view, 0 won't.
        // }
      }
      return isWidth ? _halfWidth : _halfHeight;
    }
  }

  _updateDeviceName(ChannelProvider channelProvider) async {
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    await mirrorStateProvider.setDeviceName(
        AppPreferences().instanceName, channelProvider.displayCode);
  }

  _showPinCodeDialog(BuildContext context, MirrorStateProvider mirror) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        pinDialogContextList.add(dialogContext);
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
                        Consumer<MirrorStateProvider>(
                          builder: (context, mirror, child) {
                            return Text(
                              mirror.pinCode,
                              style: const TextStyle(fontSize: 28),
                            );
                          },
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
                            Navigator.pop(context);
                          }
                          pinDialogContextList.clear();
                        }
                        mirror.clearPinCode();
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
  }

  _showAuthDialog(BuildContext context, MirrorStateProvider mirror) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        var width = MediaQuery.of(context).size.width / 3;
        var height = MediaQuery.of(context).size.height / 4;
        double minHeight = min(
            (HybridConnectionList().getMirrorMap().length * height).toDouble(),
            500.0);
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
                itemCount: HybridConnectionList()
                    .getMirrorMap()
                    .values
                    .where((request) => request.mirrorState == MirrorState.idle)
                    .length,
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
                            HybridConnectionList()
                                .getMirrorMap()
                                .values
                                .where((request) =>
                                    request.mirrorState == MirrorState.idle)
                                .toList()[index]
                                .mirrorId
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
                                //TODO: found that AirPlay icon on iMac keeps under working state even calling clearRequestMirrorId()
                                Navigator.pop(dialogContext);
                                Home.isShowAuthDialog.value = false;
                                var mirrorId = HybridConnectionList()
                                    .getMirrorMap()
                                    .values
                                    .where((request) =>
                                        request.mirrorState == MirrorState.idle)
                                    .toList()[index]
                                    .mirrorId;
                                mirror.clearRequestMirrorId(mirrorId);
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
                                Navigator.pop(dialogContext);
                                Home.isShowAuthDialog.value = false;
                                String? mirrorId = HybridConnectionList()
                                    .getMirrorMap()
                                    .values
                                    .where((request) =>
                                        request.mirrorState == MirrorState.idle)
                                    .toList()[index]
                                    .mirrorId;
                                mirror.setAcceptMirrorId(mirrorId);
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
  }
}
