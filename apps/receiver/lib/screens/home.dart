import 'dart:async';
import 'dart:io';

import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleState: $state');
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      channelProvider.updateAllAudioEnableState(false);
      mirrorStateProvider.updateAudioEnable(false);
      Provider.of<ChannelProvider>(context, listen: false).disconnectServer();
    } else if (state == AppLifecycleState.resumed) {
      channelProvider.updateAllAudioEnableState(true);
      mirrorStateProvider.updateAudioEnable(true);
      Provider.of<ChannelProvider>(context, listen: false)
          .getDisplayCode(AppInstanceCreate().displayInstanceID);
      Provider.of<ChannelProvider>(context, listen: false)
          .connectServer(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    return WillPopScope(
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
                                  Consumer<ChannelProvider>(
                                    builder: (context, provider, child) {
                                      return WebRTCView(index: index);
                                    },
                                  ),
                                  SplitScreenFunction(
                                    index: index,
                                    channelProvider:
                                    Provider.of<ChannelProvider>(context),
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
              Consumer<ChannelProvider>(
                builder: (context, provider, child) {
                  if (Provider.of<ChannelProvider>(context).showMode == false) {
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
              const MirrorView(),
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
      onWillPop: () async {
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
            try {
              _showSnackBarMessage(S.of(context).main_status_go_background);
              await Future.delayed(const Duration(seconds: 1));
              _androidAppRetain.invokeMethod('sendToBackground');
              return Future.value(false);
            } catch (e) {
              printInDebug(e, type: runtimeType);
              return Future.value(true);
            }
          }
        } else {
          return Future.value(true);
        }
      },
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

  double _getWidthHeight(int selection, bool isWidth) {
    if (Home.enlargedScreenPositionIndex.value == selection) {
      // enlarged screen
      return isWidth ? _fullWidth : _fullHeight;
    } else if (Home.enlargedScreenPositionIndex.value != null) {
      // one of the screens is enlarged
      return 0; // MUST use 1 to create view, 0 won't.
    } else {
      // no enlarged screen
      if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
        if (selection ==
            SplitScreen.mapSplitScreen.value[keySplitScreenLastId]) {
          return isWidth ? _fullWidth : _fullHeight;
        } else {
          return 0; // MUST use 1 to create view, 0 won't.
        }
      }
      return isWidth ? _halfWidth : _halfHeight;
    }
  }
}
