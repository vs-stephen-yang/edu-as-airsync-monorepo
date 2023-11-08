import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_textfield.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentIdleNetOff extends StatelessWidget {
  PresentIdleNetOff({super.key});

  final GlobalKey<PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);

    return Container(
      height: 300,
      padding:
      const EdgeInsets.only(left: 20, top: 60.0, right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.presentIdleOffBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic_net_off.png',
                  height: 23,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text(
                    'Internet mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                onPressed: () {
                  channelProvider.currentMode = Mode.internet;
                },
                icon: const Icon(
                  Icons.arrow_circle_left,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}
