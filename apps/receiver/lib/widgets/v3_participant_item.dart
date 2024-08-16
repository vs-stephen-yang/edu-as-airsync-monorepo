import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motion_toast/motion_toast.dart';

class V3ParticipantItem extends StatelessWidget {
  const V3ParticipantItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    RTCConnector rtcConnector =
        HybridConnectionList().getRtcConnectorMap().values.toList()[index];
    String presenterId = rtcConnector.clientId ?? '';
    return SizedBox(
      width: 283,
      height: 37,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 160,
                height: 18,
                child: AutoSizeText(
                  rtcConnector.senderNameWithEllipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurface,
                  ),
                  maxLines: 1,
                ),
              ),
              AutoSizeText(
                (HybridConnectionList().isPresenterStreaming(presenterId))
                    ? S.of(context).v3_participant_item_casting
                    : S.of(context).v3_participant_item_connected,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color:
                      (HybridConnectionList().isPresenterStreaming(presenterId))
                          ? context.tokens.color.vsdslColorSuccess
                          : context.tokens.color.vsdslColorOnSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!HybridConnectionList().isPresenterStreaming(presenterId))
            SizedBox(
              width: 80,
              height: 27,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: context.tokens.color.vsdslColorSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: context.tokens.radii.vsdslRadiusFull,
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  _presenterOnOff(context, rtcConnector, presenterId);
                },
                child: AutoSizeText(
                  S.of(context).v3_participant_item_share,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
                ),
              ),
            ),
          if (HybridConnectionList().isPresenterStreaming(presenterId))
            SizedBox(
              width: 27,
              height: 27,
              child: IconButton(
                icon: const Image(
                  image: Svg('assets/images/ic_participant_stop.svg'),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  _presenterOnOff(context, rtcConnector, presenterId);
                },
              ),
            ),
          const SizedBox(width: 5),
          SizedBox(
            width: 27,
            height: 27,
            child: IconButton(
              icon: const Image(
                image: Svg('assets/images/ic_participant_close.svg'),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _sendPresenterRemove(context, rtcConnector);
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: rtcConnector.reconnectChannelStateNotifier,
            builder:
                (BuildContext context, ReconnectState value, Widget? child) {
              if (rtcConnector.clickButtonWhenReconnect) {
                if (value == ReconnectState.success) {
                  rtcConnector.clickButtonWhenReconnect = false;
                  V3Toast()
                      .makeReconnectToast(value,
                          S.of(context).main_feature_reconnect_success_toast)
                      ?.show(context);
                  rtcConnector.reconnectChannelStateNotifier.value =
                      ReconnectState.idle;
                } else if (value == ReconnectState.fail) {
                  rtcConnector.clickButtonWhenReconnect = false;
                  V3Toast()
                      .makeReconnectToast(value,
                          S.of(context).main_feature_reconnect_fail_toast)
                      ?.show(context);
                  rtcConnector.reconnectChannelStateNotifier.value =
                      ReconnectState.idle;
                }
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  _presenterOnOff(
      BuildContext context, RTCConnector rtcConnector, String presenterId) {
    if (!rtcConnector.isChannelConnectAvailable()) {
      rtcConnector.clickButtonWhenReconnect = true;
      V3Toast()
          .makeReconnectToast(
              rtcConnector.reconnectChannelState,
              rtcConnector.reconnectChannelState == ReconnectState.reconnecting
                  ? S.of(context).main_feature_reconnecting_toast
                  : S.of(context).main_feature_reconnect_fail_toast)
          ?.show(context);
      return;
    }
    if (HybridConnectionList().isPresenterNotStopStreaming(presenterId)) {
      // waitForStream and streaming
      AppAnalytics().trackEventModeratorPresenterStop();
      rtcConnector.sendStopPresent();
    } else {
      if (HybridConnectionList().getPresentingCount() >= 4) {
        MotionToast(
          primaryColor: Colors.grey,
          description: AutoSizeText(
            S.of(context).toast_maximum_split_screen,
            maxLines: 1,
          ),
          displaySideBar: false,
        ).show(context);
        return;
      }
      AppAnalytics().trackEventModeratorPresenterPresent();
      rtcConnector.sendAllowPresent();
    }
  }

  _sendPresenterRemove(BuildContext context, RTCConnector rtcConnector) async {
    if (!rtcConnector.isChannelConnectAvailable()) {
      rtcConnector.clickButtonWhenReconnect = true;
      V3Toast()
          .makeReconnectToast(
              rtcConnector.reconnectChannelState,
              rtcConnector.reconnectChannelState == ReconnectState.reconnecting
                  ? S.of(context).main_feature_reconnecting_toast
                  : S.of(context).main_feature_reconnect_fail_toast)
          ?.show(context);
      return;
    }
    AppAnalytics().trackEventModeratorPresentersRemove();
    await rtcConnector.disconnectPeerConnection();
    await rtcConnector.disconnectChannel(reason: 'User removed the presenter');
  }
}
