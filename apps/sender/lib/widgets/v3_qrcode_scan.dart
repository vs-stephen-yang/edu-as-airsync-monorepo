import 'dart:io';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

typedef QRcodeConnectResult = Function(bool success);

class V3QRcodeScan extends StatefulWidget {
  const V3QRcodeScan({super.key});

  @override
  State<V3QRcodeScan> createState() => _V3QRcodeScanState();
}

class _V3QRcodeScanState extends State<V3QRcodeScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool connecting = false;
  static const double HOLE_SIZE = 228;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
        Column(
          children: [
            const Spacer(),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xA3151C32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.current.v3_scan_qr_reminder,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 0.11,
                      letterSpacing: -0.16,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Image.asset('assets/images/img_scanframe_scan.png',
                width: HOLE_SIZE, height: HOLE_SIZE, fit: BoxFit.fitWidth),
            const Spacer(),
            GestureDetector(
              child: const Image(
                width: 56,
                height: 56,
                image: Svg('assets/images/ic_qr_close.svg'),
              ),
              onTap: () {
                Provider.of<PresentStateProvider>(context, listen: false)
                    .presentMainPage();
              },
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) async {
        if (connecting) return;
        String? inputString = scanData.code;
        if (inputString != null) {
          Uri uri = Uri.parse(inputString);
          String? quickConnectValue = uri.queryParameters['quick_connect'];
          if (quickConnectValue != null) {
            List<String> parts = quickConnectValue.split('@');
            if (parts.length == 3) {
              String code = parts[0];
              String otp = parts[1];
              // String ver = parts[2];
              connecting = true;
              await startConnect(displayCode: code, otp: otp);
            }
          }
        }
      },
    );
  }

  Future<void> startConnect(
      {required String displayCode, required String otp}) async {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    AppAnalytics.instance.trackEvent(
      'enter_display_code',
      EventCategory.menu,
      properties: {
        'target': 'type',
      },
    );

    AppAnalytics.instance.setGlobalProperty('display_code', displayCode);
    AppAnalytics.instance.trackEvent('click_connect', EventCategory.session);

    await channelProvider.presentEnd(goIdleState: false);
    await channelProvider.startConnect(
      formattedDisplayCode: displayCode,
      otp: otp,
      presentStateProvider: presentStateProvider,
      qrCallback: (success) {
        connecting = success;
      },
    );
  }
}
