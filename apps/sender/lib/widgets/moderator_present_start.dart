import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/present_timer.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModeratorPresentStart extends StatelessWidget {
  ModeratorPresentStart({super.key, this.countStartTime = 0});

  final ValueNotifier<bool> _presentingState = ValueNotifier(true);
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();
  final int countStartTime;

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    var textStyle30 = const TextStyle(color: Colors.white, fontSize: 28);
    return Column(
      children: [
        const Expanded(flex: 2, child: SizedBox()),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Text(
            S.of(context).present_time,
            style: textStyle30,
          ),
        ),
        PresentTimer(
          presentingState: _presentingState,
          countStartTime: countStartTime,
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: ValueListenableBuilder(
                    valueListenable: _presentingState,
                    builder: (BuildContext context, value, Widget? child) {
                      return InkWell(
                        onTap: () {
                          _presentingState.value = !_presentingState.value;
                          if (_presentingState.value) {
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
                            const Padding(padding: EdgeInsets.only(left: 8)),
                            Text(
                              value
                                  ? S.of(context).present_state_pause
                                  : S.of(context).present_state_resume,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppConstants.fontSize_normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 38.0, top: 20.0),
                  child: InkWell(
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
                        const Padding(padding: EdgeInsets.only(left: 8)),
                        Text(
                          S.of(context).present_state_stop,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppConstants.fontSize_normal,
                          ),
                        ),
                      ],
                    ),
                  ),
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
