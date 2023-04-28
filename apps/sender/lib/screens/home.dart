import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              appConfig?.appName ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              appConfig?.appVersion ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              appConfig?.appVersionCode.toString() ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
