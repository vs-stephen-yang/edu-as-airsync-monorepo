import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ver ${appConfig?.appVersion}',
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 16,
              ),
            ),
          ),
          const Text(
            'myViewBoard Display',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
            ),
          ),
        ],
      ),
    );
  }
}
