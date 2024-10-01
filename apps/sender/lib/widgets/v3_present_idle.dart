import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3PresentIdle extends StatelessWidget {
  V3PresentIdle({super.key});

  final GlobalKey<V3PresentIdleButtonState> presentBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    DemoProvider demoProvider = Provider.of<DemoProvider>(context);
    bool presentBtnEnable = false;
    String displayCode = '', password = '';
    bool isDisplayCodeSelectedFromHistory = false;

    return Stack(
      children: [
        Positioned(
            top: 24,
            left: 8,
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Image(
                  image: Svg('assets/images/v3_ic_qrcode.svg'),
                ),
                onPressed: () {},
              ),
            )),
        Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: Svg('assets/images/v3_ic_airsync.svg'),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 35)),
                  V3PresentIdleButton(
                    key: presentBtnKey,
                    fixedSize: const Size(300, 48),
                    onPressed: () async {
                      AppAnalytics.instance
                          .trackEvent('enter_display_code', properties: {
                        'target': isDisplayCodeSelectedFromHistory
                            ? 'select'
                            : 'type',
                      });

                      AppAnalytics.instance
                          .setGlobalProperty('display_code', displayCode);

                      AppAnalytics.instance.trackEvent('click_connect');

                      if (!presentBtnEnable) return;
                      await channelProvider.presentEnd(goIdleState: false);
                      if (displayCode == "00000000000" && password == "0000") {
                        demoProvider.isDemoMode = true;
                        demoProvider.presentSelectRoleDemoPage();
                      } else {
                        channelProvider.startConnect(
                            formattedDisplayCode: displayCode,
                            otp: password,
                            presentStateProvider: presentStateProvider);
                      }
                    },
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
