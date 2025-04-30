import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

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
                color:
                    context.tokens.color.vsdswColorSurface1000.withAlpha(163),
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
                    style: TextStyle(
                      color: context.tokens.color.vsdswColorNeutralInverse,
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
                excludeFromSemantics: true,
                width: HOLE_SIZE,
                height: HOLE_SIZE,
                fit: BoxFit.fitWidth),
            const Spacer(),
            V3Focus(
              label: S.of(context).v3_lbl_qr_close,
              identifier: 'v3_qa_qr_close',
              child: InkWell(
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
        if (inputString != null && isValidQuickConnectUrl(inputString)) {
          Uri? uri = Uri.tryParse(inputString);
          String? quickConnectValue = uri?.queryParameters['quick_connect'];
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

  bool isValidQuickConnectUrl(String url) {
    // 確保 quick_connect參數符合"數字@數字@字母或數字_字母"格式
    final RegExp quickConnectPattern = RegExp(r"quick_connect=\d+@\d+@[\w.]+");
    return quickConnectPattern.hasMatch(url);
  }

  Future<void> startConnect(
      {required String displayCode, required String otp}) async {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    trackEvent(
      'enter_display_code',
      EventCategory.menu,
      properties: {
        'target': 'type',
      },
    );

    AppAnalytics.instance.setGlobalProperty('display_code', displayCode);
    trackEvent('click_connect', EventCategory.session);

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
