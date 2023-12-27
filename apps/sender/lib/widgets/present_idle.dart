
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_lan_off.dart';
import 'package:display_cast_flutter/widgets/present_idle_lan_on.dart';
import 'package:display_cast_flutter/widgets/present_idle_net_off.dart';
import 'package:display_cast_flutter/widgets/present_idle_net_on.dart';
import 'package:display_cast_flutter/widgets/present_idle_textfield.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class PresentIdle extends StatelessWidget {
  PresentIdle({super.key});

  final GlobalKey<PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppConstants.viewStateMenuWidth,
              child: channelProvider.currentMode == Mode.internet? PresentIdleNetOn(): PresentIdleNetOff(),
            ),
            SizedBox(
              width: AppConstants.viewStateMenuWidth,
              child: channelProvider.currentMode == Mode.lan? PresentIdleLanOn(): PresentIdleLanOff(),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.all(10)),
        // const SizedBox(
        //   height: 20,
        // ),
        Row(
          children: [
            const Spacer(),
            Flexible(child: Column(
              children: [
                InkWell(
                  onTap: () {
                    channelProvider.presentSettingPage();
                    // presentStateProvider.setViewState(ViewState.settings);
                  },
                  child: Row(
                    children: [
                      Flexible(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 5),
                            child: const Icon(
                              Icons.settings,
                              size: 18,
                              color: Colors.white,
                            ),
                          )),
                      Flexible(
                        flex: 1,
                        child: Text(
                          S.of(context).main_setting,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),),
                      const Flexible(flex: 1, child: SizedBox()),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 5),
                        child: const Image(
                          height: 18,
                          image: Svg('assets/images/touch_app_black.svg'),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        S.of(context).main_touch_back,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child:
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TouchBackButton(
                          key: touchBtnKey,
                          initialValue: channelProvider.touchBack, //presentStateProvider.touchBack,
                          onPressed: (state) {
                            channelProvider.touchBack = state;
                            // presentStateProvider.setTouchBack(state);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

