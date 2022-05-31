import 'dart:math' as math;

import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/blocs/display_code/display_code_bloc.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/webrtc_info.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainInfo extends StatefulWidget {
  const MainInfo({Key? key}) : super(key: key);

  @override
  State createState() => _MainInfoState();
}

class _MainInfoState extends State<MainInfo> {
  late DisplayCodeBloc _displayCodeBloc;
  bool _isEyeOpen = true;

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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: BlocProvider(
        create: (context) => _displayCodeBloc,
        child: BlocBuilder<DisplayCodeBloc, DisplayCodeState>(
          builder: (context, state) {
            if (state is DisplayCodeSuccess) {
              ControlSocket.getInstance().connect(AppConfig.of(context));
            }
            return Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  children: <Widget>[
                    Text(
                      S.of(context).main_content_display_code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getDisplayCode(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      S.of(context).main_content_one_time_password,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: <Widget>[
                        Text(
                          _isEyeOpen ? _displayCodeBloc.otp : "XXXX",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  //value: 0.3, // todo: otp timer
                                  strokeWidth: 4,
                                  backgroundColor: Colors.black,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                            Text(
                              WebRTCInfo.getInstance().otpTimer.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEyeOpen = !_isEyeOpen;
                            });
                          },
                          icon: Image.asset(
                            _isEyeOpen
                                ? 'assets/images/ic_eye_open.png'
                                : 'assets/images/ic_eye_close.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: !WebRTCInfo.getInstance()
                      .featureList
                      .contains('Moderator'),
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    children: <Widget>[
                      Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: <Widget>[
                          Container(
                            height: 2,
                            width: 50,
                            color: Colors.white,
                          ),
                          Text(
                            S.of(context).main_content_scan_or,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            height: 2,
                            width: 50,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      QrImage(
                        data: AppInstanceCreate().instanceID,
                        version: QrVersions.auto,
                        size: 120.0,
                        backgroundColor: Colors.white,
                        embeddedImage:
                            const Svg('assets/images/ic_logo_my.svg'),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          // Cannot set too large, will scan failure!!
                          size: const Size(25, 25),
                        ),
                      ),
                      Text(
                        S.of(context).main_content_scan_to_enroll,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _getDisplayCode() {
    String result = '';
    for (int i = 0; i < WebRTCInfo.getInstance().displayCode.length; i++) {
      if (i % 3 == 0 && result.isNotEmpty) {
        result += '-';
      }
      result += WebRTCInfo.getInstance().displayCode.substring(i, i + 1);
    }
    return result;
  }
}
