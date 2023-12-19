
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    // PresentStateProvider presentStateProvider = Provider.of<PresentStateProvider>(context);
    return SizedBox(
      width: AppConstants.viewStateMenuWidth,
      height: AppConstants.viewStateMenuHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        channelProvider.presentMainPage();
                        // presentStateProvider.setViewState(ViewState.idle);
                      },
                      child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,)),
                  const Icon(Icons.settings, color: Colors.white,),
                ],
              )),
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(flex: 1,),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Divider(color: Colors.white12,),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: InkWell(
              onTap: () async {
                var url = Uri.parse('https://myviewboard.com/kb/en_US/display');
                await launchUrl(url);
              },
              child: const Text(
                'Knowledge base',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: InkWell(
              onTap: () {
                channelProvider.presentLanguagePage();
                // presentStateProvider.setViewState(ViewState.language);
              },
              child: const Text(
                'Language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Divider(color: Colors.white12,),
          ),
        ],
      ),
    );
  }
}

