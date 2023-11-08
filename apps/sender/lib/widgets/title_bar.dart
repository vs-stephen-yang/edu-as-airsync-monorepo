import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      width: 300,
      child: Row(
        children: [
          Image.asset('assets/images/ic_launcher.png', height: 46,),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              'AirSync',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5.0)),
          Text(
            'Ver ${appConfig?.appVersion}',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
