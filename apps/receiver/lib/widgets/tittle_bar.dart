import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/focus_text_button.dart';
import 'package:display_flutter/widgets/text_clock.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State createState() => _TitleBarStates();
}

class _TitleBarStates extends State<TitleBar> {
  int debugCounter = 0;
  final int openDebugCounter = 5;

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset('assets/images/ic_launcher.png', height: 46),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: V3AutoHyphenatingText(
                  'AirSync',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              FocusTextButton(
                onClick: () {
                  debugCounter++;
                  if (debugCounter == openDebugCounter) {
                    _showMenuDialog(DebugSwitch());
                    debugCounter = 0;
                  }
                },
                child: V3AutoHyphenatingText(
                  'Ver ${appConfig?.appVersion ?? ' '}',
                  style: const TextStyle(
                    color: AppColors.primaryWhiteA50,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              const TextClock(),
            ],
          ),
          V3AutoHyphenatingText(
            AppConfig.of(context)?.settings.airSyncUrl ?? '',
            style: const TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }

  _showMenuDialog(Widget widget) async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return widget;
      },
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }
}
