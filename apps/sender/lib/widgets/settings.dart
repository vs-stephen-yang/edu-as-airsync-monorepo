import 'dart:io';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return SizedBox(
      width: AppConstants.viewStateMenuWidth,
      height: AppConstants.viewStateMenuHeight,
      child: Column(
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
                        channelProvider.presentMainPage();
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
                    fontSize: AppConstants.fontSize_title,
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
                var url = Uri.parse('https://myviewboard.com/kb/en_US/display');
                await launchUrl(url);
              },
              child: Text(
                S.of(context).settings_knowledge_base,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSize_normal,
                ),
              ),
            ),
          ),
          if (!kIsWeb && Platform.isMacOS)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              child: InkWell(
                onTap: () async {
                  var url = Uri.parse('https://myviewboard.com/kb/');
                  await launchUrl(url);
                },
                child: Text(
                  S.of(context).settings_audio_configuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.fontSize_normal,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: InkWell(
              onTap: () {
                channelProvider.presentLanguagePage();
              },
              child: Text(
                S.of(context).main_language,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSize_normal,
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
        ],
      ),
    );
  }
}
