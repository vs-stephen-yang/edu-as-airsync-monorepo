import 'dart:io';

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/tittle_bar.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

final GlobalKey<StreamFunctionStates> streamFunctionKey = GlobalKey();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static ValueNotifier<bool> showTitleBottomBar = ValueNotifier(true);
  static ValueNotifier<bool> showCloudOff = ValueNotifier(false);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;
  final List<bool> _isSelectedList = List.filled(4, false, growable: false);
  static const _androidAppRetain =
      MethodChannel("com.mvbcast.crosswalk/android_app_retain");

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
                builder: (BuildContext context, Map<String, dynamic> value,
                    Widget? child) {
                  _updateSizeForSelected(int selection) {
                    setState(() {
                      if (value[keySplitScreenEnable]) {
                        for (int i = 0; i < _isSelectedList.length; i++) {
                          if (i == selection) {
                            _isSelectedList[i] = !_isSelectedList[i];
                          } else {
                            _isSelectedList[i] = false;
                          }
                        }
                      } else {
                        _isSelectedList.fillRange(
                            0, _isSelectedList.length, false);
                      }
                    });
                  }

                  double _getWidthHeight(int selection, bool isWidth) {
                    if (value[keySplitScreenEnable]) {
                      // split screen enabled
                      if (_isSelectedList[selection]) {
                        // selected item
                        return isWidth ? _fullWidth : _fullHeight;
                      } else if (_isSelectedList.contains(true)) {
                        // has any item selected
                        return 0;
                      } else {
                        // no any item selected
                        if (value[keySplitScreenCount] < 1) {
                          if (selection == value[keySplitScreenLastId]) {
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

                  List<Widget> webrtcWidgets = List.generate(
                      value[keySplitScreenEnable] ? 4 : 1, (index) {
                    double? left, top, right, bottom;
                    double? iconLeft, iconTop, iconRight, iconBottom;
                    if (index == 1) {
                      right = 0;
                      top = 0;
                      iconLeft = 20;
                      iconBottom = 20;
                    } else if (index == 2) {
                      left = 0;
                      bottom = 0;
                      iconRight = 20;
                      iconTop = 20;
                    } else if (index == 3) {
                      right = 0;
                      bottom = 0;
                      iconLeft = 20;
                      iconTop = 20;
                    } else {
                      // index 0 and default.
                      left = 0;
                      top = 0;
                      iconRight = 20;
                      iconBottom = 20;
                    }

                    return Positioned(
                      left: left,
                      top: top,
                      right: right,
                      bottom: bottom,
                      child: Stack(
                        children: <Widget>[
                          AnimatedContainer(
                            width: _getWidthHeight(index, true),
                            height: _getWidthHeight(index, false),
                            alignment: Alignment.center,
                            curve: Curves.linear,
                            duration: Duration(
                                seconds: _isSelectedList[index] ? 1 : 0),
                            child: WebRTCNativeView(
                              useHybrid: false,
                              onWebRTCNativeViewCreatedCallback:
                                  ControlSocket().addWebRtcController,
                            ),
                          ),
                          Positioned(
                              left: iconLeft,
                              top: iconTop,
                              right: iconRight,
                              bottom: iconBottom,
                              child: Visibility(
                            visible: value[keySplitScreenEnable] && ControlSocket().isPresenting(index: index) && !_isSelectedList[index],
                                child: IconButton(
                                  icon: Image(
                                      image: Svg('assets/images/ic_zoom_in.svg',
                                          size: Size.square(48))),
                                  onPressed: () {
                                    _updateSizeForSelected(index);
                                  },
                                ),
                              )),
                          Positioned(
                              right: 0,
                              bottom: 0,
                              child: Visibility(
                                visible: value[keySplitScreenEnable] && ControlSocket().isPresenting() && _isSelectedList[index],
                                child: IconButton(
                                  icon: Image(
                                      image: Svg('assets/images/ic_zoom_out.svg',
                                          size: Size.square(48))),
                                  onPressed: () {
                                    _updateSizeForSelected(index);
                                  },
                                ),
                              )),
                        ],
                      ),
                    );
                  });

                  return Stack(
                    children: webrtcWidgets,
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
                        Visibility(
                          visible: AppInstanceCreate().isInstalledInVBS100,
                          child: const Positioned(
                              left: 0, right: 0, bottom: 0, child: VbsOTA()),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const MainInfo(),
              const Positioned(
                child: StatusBar(),
              ),
              Positioned(
                left: 20,
                bottom: 0,
                child: StreamFunction(key: streamFunctionKey),
              ),
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
                          const Image(
                              image: Svg('assets/images/ic_cloud_off.svg')),
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
              _showSnackBarMessage('Display App goes to the background.');
              await Future.delayed(const Duration(seconds: 1));
              _androidAppRetain.invokeMethod('sendToBackground');
              return Future.value(false);
            } catch (e) {
              print(e);
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
}
