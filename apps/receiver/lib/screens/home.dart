import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/blocs/display_code/display_code_bloc.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/tittle_bar.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static ValueNotifier<bool> showTitleBottomBar = ValueNotifier(true);
  static ValueNotifier<bool> showMainInfo = ValueNotifier(true);
  static ValueNotifier<bool> showStreamFunction = ValueNotifier(true);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DisplayCodeBloc _displayCodeBloc;
  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;
  final List<bool> _isSelectedList = List.filled(4, false, growable: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _displayCodeBloc = DisplayCodeBloc(
        AppConfig.of(context)!.settings.apiGateway,
        AppInstanceCreate().displayInstanceID,
        AppConfig.of(context)!.appVersion);
    if (_displayCodeBloc.state is DisplayCodeInitial) {
      _displayCodeBloc.add(GetDisplayCode());
    }
  }

  @override
  void dispose() {
    ControlSocket().disconnectControlSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: SplitScreen.splitScreenEnabled,
              builder: (BuildContext context, bool value, Widget? child) {
                _updateSizeForSelected(int selection) {
                  setState(() {
                    if (value) {
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
                  if (value) {
                    // split screen enabled
                    if (_isSelectedList[selection]) {
                      // selected item
                      return isWidth ? _fullWidth : _fullHeight;
                    } else if (_isSelectedList.contains(true)) {
                      // has any item selected
                      return 0;
                    } else {
                      // no any item selected
                      return isWidth ? _halfWidth : _halfHeight;
                    }
                  } else {
                    // split screen disabled
                    return isWidth ? _fullWidth : _fullHeight;
                  }
                }

                List<Widget> webrtcWidgets =
                    List.generate(value ? 4 : 1, (index) {
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

                  return Positioned(
                    left: left,
                    top: top,
                    right: right,
                    bottom: bottom,
                    child: GestureDetector(
                      onDoubleTap: () => _updateSizeForSelected(index),
                      child: AnimatedContainer(
                        width: _getWidthHeight(index, true),
                        height: _getWidthHeight(index, false),
                        alignment: Alignment.center,
                        curve: Curves.linear,
                        duration:
                            Duration(seconds: _isSelectedList[index] ? 1 : 0),
                        child: WebRTCNativeView(
                          useHybrid: false,
                          onWebRTCNativeViewCreatedCallback:
                              ControlSocket().addWebRtcController,
                        ),
                      ),
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
            BlocProvider(
              create: (context) => _displayCodeBloc,
              child: BlocBuilder<DisplayCodeBloc, DisplayCodeState>(
                builder: (context, state) {
                  if (state is DisplayCodeSuccess) {
                    ControlSocket().connect(AppConfig.of(context));
                  }
                  return ValueListenableBuilder(
                    valueListenable: Home.showMainInfo,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Visibility(
                          visible: value,
                          child: MainInfo(otpCode: _displayCodeBloc.otp));
                    },
                  );
                },
              ),
            ),
            ValueListenableBuilder(
              valueListenable: Home.showStreamFunction,
              builder: (BuildContext context, bool value, Widget? child) {
                return Visibility(
                  visible: value,
                  child: const Positioned(
                      left: 20, bottom: 140, child: StreamFunction()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
