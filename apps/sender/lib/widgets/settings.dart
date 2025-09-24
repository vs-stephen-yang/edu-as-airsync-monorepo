import 'dart:io';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/screens/debug_switch.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/focus_text_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State createState() => _Settings();
}

class _Settings extends State<Settings> {
  int debugCounter = 0;
  final int openDebugCounter = 5;

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    AppConfig? appConfig = AppConfig.of(context);
    return SizedBox(
      width: AppConstants.viewStateMenuWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        presentStateProvider.presentMainPage();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  S.of(context).main_setting,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: AppConstants.fontSizeTitle,
                  ),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Divider(
              color: Colors.white12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: InkWell(
              onTap: () async {
                var url = Uri.parse('https://myviewboard.com/kb/t_CN');
                await launchUrl(url);
              },
              child: Text(
                S.of(context).settings_knowledge_base,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeNormal,
                ),
              ),
            ),
          ),
          if (!kIsWeb && Platform.isMacOS)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              child: InkWell(
                onTap: () async {
                  var url = Uri.parse(
                      'https://myviewboard.com/kb/t_CN/airsync/what-is-airsync');
                  await launchUrl(url);
                },
                child: Text(
                  S.of(context).settings_audio_configuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.fontSizeNormal,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: InkWell(
              onTap: () {
                presentStateProvider.presentLanguagePage();
              },
              child: Text(
                S.of(context).main_language,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeNormal,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Divider(
              color: Colors.white12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: FocusTextButton(
              onClick: () {
                debugCounter++;
                if (debugCounter == openDebugCounter) {
                  _showMenuDialog(const DebugSwitch());
                  debugCounter = 0;
                }
              },
              child: Text(
                'Ver ${appConfig?.appVersion}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ),
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
