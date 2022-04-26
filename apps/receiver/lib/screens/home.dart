import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _displayCode = '';
  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: WebRTCNativeView(
                onWebRTCNativeViewCreatedCallback:
                    _webRTCNativeViewCreatedCallback,
              ),
            ),
            FittedBox(
              child: Text(
                appConfig != null ? appConfig.settings.mainDisplayUrl : '',
                style: const TextStyle(color: Colors.blue, fontSize: 30),
              ),
            ),
            FittedBox(
              child: Text(
                'Display Code: $_displayCode',
                style: const TextStyle(color: Colors.blue, fontSize: 30),
              ),
            ),
            FittedBox(
              child: Text(
                'OTP: $_otpCode',
                style: const TextStyle(color: Colors.blue, fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _webRTCNativeViewCreatedCallback(WebRTCNativeViewController controller) {
    controller.channel.setMethodCallHandler((MethodCall call) async {
      setState(() {
        if (call.method == "setDisplayCode") {
          _displayCode = call.arguments as String;
        } else if (call.method == "setOtpCode") {
          _otpCode = call.arguments as String;
        }
      });
      return;
    });
  }
}
