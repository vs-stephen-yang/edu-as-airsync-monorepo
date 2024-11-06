import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/webrtc_helper.dart';
import 'package:display_cast_flutter/widgets/high_quality_button.dart';
import 'package:display_cast_flutter/widgets/present_timer.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModeratorPresentStart extends StatelessWidget {
  ModeratorPresentStart({super.key});

  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  void sendReconnectStateToast(
      BuildContext context, ChannelReconnectState state) {
    Toast.makeFeatureReconnectToast(
        state,
        state == ChannelReconnectState.reconnecting
            ? S.of(context).main_feature_reconnecting_toast
            : S.of(context).main_feature_reconnect_fail_toast);
  }

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
                      // Toggle current state
                      bool tempState = !presentingState.value;
                      AppAnalytics.instance.trackEvent(
                          tempState ? 'click_resume' : 'click_pause',
                          EventCategory.session);

                      // Update state
                      presentingState.value = tempState;
                      tempState
                          ? channelProvider.presentResume()
                          : channelProvider.presentPause();
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
              ValueListenableBuilder(
                  valueListenable:
                      WebRTCHelper().webRTCConnector!.reconnectStateNotifier,
                  builder: (BuildContext context, ChannelReconnectState state,
                      Widget? child) {
                    if (state == ChannelReconnectState.reconnecting) {
                      Toast.makeFeatureReconnectToast(
                          state, S.of(context).main_webrtc_reconnecting_toast);
                    } else if (state == ChannelReconnectState.success) {
                      Toast.makeFeatureReconnectToast(state,
                          S.of(context).main_webrtc_reconnect_success_toast);
                      WebRTCHelper()
                          .setReconnectState(ChannelReconnectState.idle);
                    } else if (state == ChannelReconnectState.fail) {
                      Toast.makeFeatureReconnectToast(state,
                          S.of(context).main_webrtc_reconnect_fail_toast);
                      WebRTCHelper()
                          .setReconnectState(ChannelReconnectState.idle);
                    }
                    return Container();
                  }),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  AppAnalytics.instance
                      .trackEvent('click_stop', EventCategory.session);

                  channelProvider.presentStop();
                  Provider.of<PresentStateProvider>(context, listen: false)
                      .presentModeratorWaitPage();
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
              if (!kIsWeb)
                HighQualityButton(
                    onPressed: (state) {
                      channelProvider.presentChangeHighQuality(
                          isHighQuality: state);
                    },
                    initialValue:
                        channelProvider.profileStore.selectedProfile ==
                            ProfileStore.videoQualityFirstProfile),
              if (WebRTCHelper().showTouchBack())
                TouchBackButton(
                  key: touchBtnKey,
                  initialValue: WebRTCHelper().getTouchBack(),
                  onPressed: (state) {
                    AppAnalytics.instance
                        .trackEvent('click_touchback', EventCategory.session);
                    WebRTCHelper().setTouchBack(state);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
