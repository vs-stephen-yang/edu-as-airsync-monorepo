import 'dart:io';

import 'package:display_cast_flutter/utilities/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3SplashScreen extends StatefulWidget {
  const V3SplashScreen({super.key});

  @override
  State<V3SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<V3SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 2), () {
      navService.pushNamedAndRemoveUntil(
        AppPreferences().showEULA ? '/v3eula' : '/v3home',
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset('assets/images/v3_ic_airsync.svg'),
            Positioned(
              bottom: (Platform.isAndroid || Platform.isIOS) ? 24 : 32,
              child: Image.asset(
                'assets/images/ic_logo_viewsonic_mobile.png',
                width: 170,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
