import 'package:display_flutter/native_view/webrtc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _displayCode = '';
  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
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
