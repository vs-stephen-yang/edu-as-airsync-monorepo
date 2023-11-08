
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_textfield.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentIdleLanOff extends StatelessWidget {
  PresentIdleLanOff({super.key});

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
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              // Image.asset(
              //   'assets/images/ic_launcher.png',
              //   height: 23,
              // ),
              Icon(Icons.lan_outlined, size: 23.0, color: Colors.white,),
              Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  'LAN mode',
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
          alignment: Alignment.centerLeft,
          child: IconButton(
              onPressed: () {
                channelProvider.currentMode = Mode.lan;
              },
              icon: const Icon(
                Icons.arrow_circle_right,
                color: Colors.white,
              )),
        ),
      ]),
    );
  }


}
