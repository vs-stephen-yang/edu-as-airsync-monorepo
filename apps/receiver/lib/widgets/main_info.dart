import 'dart:math' as math;

import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/webrtc_info.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainInfo extends StatefulWidget {
  const MainInfo({Key? key, required this.otpCode}) : super(key: key);
  final String otpCode;

  @override
  State createState() => _MainInfoState();
}

class _MainInfoState extends State<MainInfo> {
  static bool _isEyeOpen = true; // use static to keep value for eye switch

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    String qrCode = '';
    if (appConfig != null) {
      if (AppInstanceCreate().isInstalledInVBS100) {
        qrCode =
            appConfig.settings.prefixQRCode + AppInstanceCreate().serialNumber;
      } else {
        qrCode =
            appConfig.settings.prefixQRCode + AppInstanceCreate().instanceID;
      }
    }
    return Container(
      padding: const EdgeInsets.all(30),
      child: Wrap(
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
                    _isEyeOpen ? widget.otpCode : "XXXX",
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
            visible: AppPreferences().entityId.isEmpty,
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
                  data: qrCode,
                  version: QrVersions.auto,
                  size: 120.0,
                  backgroundColor: Colors.white,
                  embeddedImage: const Svg('assets/images/ic_logo_my.svg'),
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
