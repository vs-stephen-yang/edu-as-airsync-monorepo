
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModeratorWait extends StatelessWidget {
  const ModeratorWait({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    // PresentStateProvider presentStateProvider = Provider.of<PresentStateProvider>(context);
    return SizedBox(
      width: AppConstants.viewStateMenuWidth,
      height: AppConstants.viewStateMenuHeight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.groups,
                color: Colors.white,
                size: 26,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  S.of(context).moderator,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
            child: Text(
              S.of(context).moderator_wait,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: ElevatedButton(
              onPressed: () {
                channelProvider.presentEnd();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red,
                fixedSize: const Size(300, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              // icon: const Image(image: Svg('assets/images/ic_exit.svg')),
              child: Text(
                S.of(context).moderator_exit,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
