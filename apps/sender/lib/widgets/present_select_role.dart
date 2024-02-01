
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class PresentSelectRole extends StatelessWidget {
  const PresentSelectRole({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
        builder: (context, channelProvider, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!kIsWeb)
                  InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                              // color: Colors.transparent,
                            ),
                            child: const Image(
                              image: Svg('assets/images/ic_receiver.svg'),
                            )),
                        const Padding(padding: EdgeInsets.all(5)),
                        const Text(
                          'Receive',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                    onTap: () {
                      channelProvider.currentRole = JoinIntentType.remoteScreen;
                      channelProvider.presentModeratorNamePage();
                    },
                  ),
                const Padding(padding: EdgeInsets.all(10)),
                InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            // color: Colors.transparent,
                          ),
                          child: const Image(
                            image: Svg('assets/images/ic_cast_screen.svg'),
                          )),
                      const Padding(padding: EdgeInsets.all(5)),
                      const Text(
                        'Cast the screen',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                  onTap: () async {
                    channelProvider.currentRole = JoinIntentType.present;
                    if (channelProvider.moderatorStatus) {
                      channelProvider.presentModeratorNamePage();
                    } else {
                      await channelProvider.beginBasicMode();
                      channelProvider.presentSelectScreenPage();
                    }
                  },
                ),
              ],
            ));
  }
}
