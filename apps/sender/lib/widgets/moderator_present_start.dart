import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/present_timer.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModeratorPresentStart extends StatelessWidget {
  ModeratorPresentStart({super.key});

  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    var textStyle28 = const TextStyle(color: Colors.white, fontSize: 28);
    var textStyle14 = const TextStyle(
        color: Colors.white, fontSize: AppConstants.fontSizeNormal);
    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).present_time,
                style: textStyle28,
              ),
              const SizedBox(height: 30),
              const PresentTimer(),
            ],
          ),
        ),
        Positioned(
          left: 30,
          bottom: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: presentingState,
                builder: (BuildContext context, value, Widget? child) {
                  return InkWell(
                    onTap: () {
                      presentingState.value = !presentingState.value;
                      if (presentingState.value) {
                        channelProvider.presentResume();
                      } else {
                        channelProvider.presentPause();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          value
                              ? Icons.pause_presentation
                              : Icons.smart_display_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          value
                              ? S.of(context).present_state_pause
                              : S.of(context).present_state_resume,
                          style: textStyle14,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  channelProvider.presentStop();
                  channelProvider.presentModeratorWaitPage();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cancel_presentation,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).present_state_stop,
                      style: textStyle14,
                    ),
                  ],
                ),
              ),
              if (channelProvider.showTouchBack())
                TouchBackButton(
                  key: touchBtnKey,
                  initialValue: channelProvider.getTouchBack(),
                  onPressed: (state) {
                    channelProvider.setTouchBack(state);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
