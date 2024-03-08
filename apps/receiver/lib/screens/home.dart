import 'dart:async';
import 'dart:io';

import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/overlay_tab_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
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
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../settings/app_config.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static ValueNotifier<bool> showTitleBottomBar = ValueNotifier(true);
  static ValueNotifier<bool> showCloudOff = ValueNotifier(false);
  static ValueNotifier<int?> enlargedScreenPositionIndex = ValueNotifier(null);
  static bool isAirplayAuth = false;

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;
  static const _androidAppRetain =
      MethodChannel('com.mvbcast.crosswalk/android_app_retain');

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    if (AppPreferences().showOverlayTab) {
      Provider.of<OverlayTabProvider>(context, listen: false)
          .openAndroidWindow(context);
    }
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
                                      .hybridConnectionList[index] != null &&
                                      HybridConnectionList()
                                          .hybridConnectionList[index]
                                      is RTCConnector)
                                    Consumer<ChannelProvider>(
                                      builder: (context, provider, child) {
                                        return WebRTCView(index: index);
                                      },
                                    ),
                                  if (HybridConnectionList()
                                      .hybridConnectionList[index] != null &&
                                      HybridConnectionList()
                                          .hybridConnectionList[index]
                                      is MirrorRequest || Home.isAirplayAuth)
                                    Consumer<MirrorStateProvider>(
                                      builder: (context, provider, child) {
                                        return MirrorView(index: index);
                                      },
                                    ),
                                  SplitScreenFunction(
                                    index: index,
                                    channelProvider:
                                    Provider.of<ChannelProvider>(context),
                                    mirrorStateProvider:
                                    Provider.of<MirrorStateProvider>(context),
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
              Consumer2<ChannelProvider, MirrorStateProvider>(
                builder: (context, provider, mirror, child) {
                  if (Provider.of<ChannelProvider>(context).showMode == false ||
                      mirror.menuOff) {
                    return const SizedBox();
                  } else {
                    return Column(
                      children: [
                        const Gap(30),
                        Text(
                          AppConfig.of(context)?.settings.airSyncUrl ?? '',
                          style: const TextStyle(fontSize: 40),
                        ),
                        const Spacer(),
                        const MainInfoInternet(),
                        const Spacer(),
                      ],
                    );
                  }
                },
              ),
              // const MirrorView(),
              const Positioned(
                child: StatusBar(),
              ),
              Visibility(
                visible: !AppInstanceCreate().isNoneTouchModel,
                child: const Positioned(
                  left: 20,
                  bottom: 0,
                  child: StreamFunction(),
                ),
              ),
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
}
