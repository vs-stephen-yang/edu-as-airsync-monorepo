import 'dart:io';

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/main_internet.dart';
import 'package:display_flutter/widgets/main_lan.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/split_screen_function.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/tittle_bar.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:display_flutter/widgets/webrtc_view.dart';
import 'package:display_flutter/widgets/webrtc_view_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  static ValueNotifier<bool> showTitleBottomBar = ValueNotifier(true);
  static ValueNotifier<bool> showCloudOff = ValueNotifier(false);
  static ValueNotifier<List<bool>> isSelectedList =
      ValueNotifier(List.filled(4, false, growable: false));

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
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      mirrorStateProvider.updateAudioEnable(false);
    } else if (state == AppLifecycleState.resumed) {
      mirrorStateProvider.updateAudioEnable(true);
      Provider.of<ChannelProvider>(context, listen: false).getDisplayCode(AppInstanceCreate().displayInstanceID);
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
                    children: List.generate(
                        value[keySplitScreenEnable] ? 4 : 1, (index) {
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
                        valueListenable: Home.isSelectedList,
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
                                  ChannelProvider.isNewUI ? Consumer<ChannelProvider>(
                                    builder: (context, provider, child) {
                                     return WebRTCView(index: index);
                                    },
                                  ): WebRTCFlutterView(
                                    callback:
                                        ControlSocket().addWebRtcController,
                                  ),
                                  Visibility(
                                    visible: SplitScreen.mapSplitScreen
                                            .value[keySplitScreenEnable] &&
                                        ControlSocket()
                                            .isPresenting(index: index),
                                    child: SplitScreenFunction(
                                      index: index,
                                      updateSize: () {
                                        _updateSizeForSelected(index);
                                      },
                                    ),
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
              ChannelProvider.isNewUI ? Consumer<ChannelProvider>(
                builder: (context, provider, child) {
                  if (provider.showMode == false) {
                    return const SizedBox();
                  } else if (provider.currentMode == Mode.internet) {
                    return MainInternetMode();
                  } else {
                    return MainLanMode();
                  }
                },
              ):const MainInfo(),
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
              if (!ChannelProvider.isNewUI)
                ValueListenableBuilder(
                  valueListenable: Home.showCloudOff,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return Visibility(
                      visible: value,
                      child: Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.cloud_off,
                              color: Colors.red,
                              size: 120,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              S.of(context).main_status_no_network,
                              style: const TextStyle(
                                color: AppColors.primary_white,
                                fontSize: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
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
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      for (int i = 0; i < Home.isSelectedList.value.length; i++) {
        if (i == selection) {
          Home.isSelectedList.value[i] = !Home.isSelectedList.value[i];
        } else {
          Home.isSelectedList.value[i] = false;
        }
      }
      // Using below method to trigger value changed.
      // https://github.com/flutter/flutter/issues/29958
      Home.isSelectedList.value = List.from(Home.isSelectedList.value);

      if (ChannelProvider.isNewUI) { //TODO:
      } else {
        ControlSocket().updateAllQuality(
            selection, Home.isSelectedList.value.contains(true));
      }
    } else {
      Home.isSelectedList.value
          .fillRange(0, Home.isSelectedList.value.length, false);
      // Using below method to trigger value changed.
      // https://github.com/flutter/flutter/issues/29958
      Home.isSelectedList.value = List.from(Home.isSelectedList.value);

      if (ChannelProvider.isNewUI) { //TODO:

      } else {
        ControlSocket().updateAllQuality(0, true);
      }
    }
  }

  double _getWidthHeight(int selection, bool isWidth) {
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      // split screen enabled
      if (Home.isSelectedList.value[selection]) {
        // selected item
        return isWidth ? _fullWidth : _fullHeight;
      } else if (Home.isSelectedList.value.contains(true)) {
        // has any item selected
        return 1; // MUST use 1 to create view, 0 won't.
      } else {
        // no any item selected
        if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
          if (selection ==
              SplitScreen.mapSplitScreen.value[keySplitScreenLastId]) {
            return isWidth ? _fullWidth : _fullHeight;
          } else {
            return 1; // MUST use 1 to create view, 0 won't.
          }
        }
        return isWidth ? _halfWidth : _halfHeight;
      }
    } else {
      // split screen disabled
      return isWidth ? _fullWidth : _fullHeight;
    }
  }
}
