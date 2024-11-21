import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class V3ParticipantItem extends StatefulWidget {
  const V3ParticipantItem(
      {super.key, required this.index, required this.isForMenuUse});

  final int index;
  final bool isForMenuUse;

  @override
  State createState() => _V3ParticipantItemState();
}

class _V3ParticipantItemState extends State<V3ParticipantItem> {
  @override
  Widget build(BuildContext context) {
    RTCConnector rtcConnector = HybridConnectionList()
        .getRtcConnectorMap()
        .values
        .toList()[widget.index];
    String presenterId = rtcConnector.clientId ?? '';
    Widget? itemParticipant;
    bool isCasting = ((rtcConnector.presentationState.index) >=
        PresentationState.streaming.index);
    bool isReceiving = rtcConnector.isModeratorShare;
    bool isControlling = false;
    if (rtcConnector.isModeratorShare) {
      // find the remoteShareConnector with same clientId as rtcConnector.
      ChannelProvider channelProvider =
          Provider.of<ChannelProvider>(context, listen: false);
      int index = channelProvider.remoteShareConnectors
          .indexWhere((item) => item.clientId == rtcConnector.clientId);
      if (index != -1) {
        isControlling =
            channelProvider.remoteShareConnectors[index].isTouchEnabled;
      }
    }

    String status = '';
    if (isControlling) {
      status = S.of(context).v3_participant_item_controlling;
      itemParticipant = ParticipantControllingFeature(
        rtcConnector: rtcConnector,
        callback: () {
          setState(() {});
        },
      );
    } else if (isReceiving) {
      status = S.of(context).v3_participant_item_receiving;
      itemParticipant = ParticipantReceivingFeature(
        rtcConnector: rtcConnector,
        callback: () {
          setState(() {});
        },
      );
    } else if (isCasting) {
      status = S.of(context).v3_participant_item_casting;
      itemParticipant = ParticipantStreamingFeature(
        rtcConnector: rtcConnector,
        presenterId: presenterId,
      );
    } else {
      itemParticipant = ParticipantStandbyFeature(
        rtcConnector: rtcConnector,
        presenterId: presenterId,
        isForMenuUse: widget.isForMenuUse,
      );
    }

    return SizedBox(
      width: widget.isForMenuUse ? 315 : 283,
      height: isCasting ? 40 : 40,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 162,
                height: 18,
                child: AutoSizeText(
                  rtcConnector.senderName ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isForMenuUse && status.isNotEmpty) ...[
                SizedBox(height: context.tokens.spacing.vsdslSpacingSm.top),
                Container(
                  height: 17,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: context.tokens.radii.vsdslRadiusSm,
                      side: BorderSide(
                        width: 1,
                        color: (isCasting || isControlling)
                            ? context.tokens.color.vsdslColorSuccess
                            : context.tokens.color.vsdslColorSurface500,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: context.tokens.spacing.vsdslSpacingXs.top,
                      horizontal: context.tokens.spacing.vsdslSpacingSm.left),
                  child: AutoSizeText(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: (isCasting || isControlling)
                          ? context.tokens.color.vsdslColorSuccess
                          : context.tokens.color.vsdslColorSurface500,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 8,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          itemParticipant,
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
}

class ParticipantStandbyFeature extends StatelessWidget {
  const ParticipantStandbyFeature({
    super.key,
    required this.rtcConnector,
    required this.presenterId,
    required this.isForMenuUse,
  });

  final RTCConnector rtcConnector;
  final String presenterId;
  final bool isForMenuUse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 27,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5.0,
              shadowColor: context.tokens.color.vsdslColorOpacitySecondaryLg,
              backgroundColor: context.tokens.color.vsdslColorPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: context.tokens.radii.vsdslRadiusFull,
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              _presenterOnOff(context, rtcConnector, presenterId);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isForMenuUse) ...[
                  SizedBox(
                    child: Image(
                      width: 16,
                      height: 16,
                      image: const Svg('assets/images/ic_arrow_to_screen.svg'),
                      color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    ),
                  ),
                  SizedBox(width: context.tokens.spacing.vsdslSpacingXs.left),
                ],
                AutoSizeText(
                  S.of(context).v3_participant_item_share,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.tokens.spacing.vsdslSpacingSm.left),
        if (isForMenuUse) ...[
          SizedBox(
            width: 27,
            height: 27,
            child: rtcConnector.senderPlatform != 'web'
                ? IconButton(
                    icon: const Image(
                      width: 16,
                      height: 16,
                      image:
                          Svg('assets/images/ic_participant_cast_device.svg'),
                    ),
                    style: IconButton.styleFrom(
                      elevation: 10.0,
                      shadowColor:
                          context.tokens.color.vsdslColorOpacitySecondaryLg,
                      backgroundColor: context.tokens.color.vsdslColorPrimary,
                      disabledBackgroundColor:
                          context.tokens.color.vsdslColorSurface500,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (!rtcConnector.isChannelConnectAvailable()) {
                        rtcConnector.clickButtonWhenReconnect = true;
                        V3Toast()
                            .makeReconnectToast(
                                rtcConnector.reconnectChannelState,
                                rtcConnector.reconnectChannelState ==
                                        ReconnectState.reconnecting
                                    ? S
                                        .of(context)
                                        .main_feature_reconnecting_toast
                                    : S
                                        .of(context)
                                        .main_feature_reconnect_fail_toast)
                            ?.show(context);
                        return;
                      }
                      rtcConnector.sendInviteRemoteScreen();
                    },
                  )
                : null,
          ),
          SizedBox(width: context.tokens.spacing.vsdslSpacingSm.left),
        ],
        SizedBox(
          width: 27,
          height: 27,
          child: IconButton(
            icon: const Image(
              image: Svg('assets/images/ic_participant_close.svg'),
            ),
            style: IconButton.styleFrom(
              elevation: 10.0,
              shadowColor: context.tokens.color.vsdslColorOpacityNeutralXs,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (isForMenuUse) {
                trackEvent(
                  'click_exit',
                  EventCategory.session,
                  participatorId: rtcConnector.clientId,
                  mode: 'webrtc',
                );
              }
              _sendPresenterRemove(context, rtcConnector);
            },
          ),
        ),
      ],
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

      rtcConnector.sendStopPresent();
    } else {
      if (HybridConnectionList().getPresentingCount() >=
          HybridConnectionList.maxHybridSplitScreen) {
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

      rtcConnector.trackSessionEvent('click_share_to_device');

      rtcConnector.sendAllowPresent();
    }
  }

  _sendPresenterRemove(BuildContext context, RTCConnector rtcConnector) async {
    rtcConnector.trackSessionEvent('click_remove_device');

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

    await rtcConnector.disconnectPeerConnection();
    await rtcConnector.disconnectChannel(reason: 'User removed the presenter');
  }
}

class ParticipantStreamingFeature extends StatelessWidget {
  const ParticipantStreamingFeature({
    super.key,
    required this.rtcConnector,
    required this.presenterId,
  });

  final RTCConnector rtcConnector;
  final String presenterId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 27,
          height: 27,
          child: IconButton(
            icon: const Image(
              image: Svg('assets/images/ic_participant_stop.svg'),
            ),
            style: IconButton.styleFrom(
              elevation: 10.0,
              shadowColor: context.tokens.color.vsdslColorOpacityNeutralXs,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              _presenterOnOff(context, rtcConnector, presenterId);
            },
          ),
        ),
      ],
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

      rtcConnector.sendStopPresent();
    } else {
      if (HybridConnectionList().getPresentingCount() >=
          HybridConnectionList.maxHybridSplitScreen) {
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

      rtcConnector.sendAllowPresent();
    }
  }
}

class ParticipantReceivingFeature extends StatelessWidget {
  const ParticipantReceivingFeature({
    super.key,
    required this.rtcConnector,
    this.callback,
  });

  final RTCConnector rtcConnector;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    return Row(
      children: [
        SizedBox(
          width: 104,
          height: 27,
          child: ElevatedButton.icon(
            onPressed: () {
              _touchBackOn(context);
            },
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: Image(
                image: Svg('assets/images/ic_cast_device_touch_back.svg'),
              ),
            ),
            label: Text(
              S.of(context).v3_cast_to_device_touch_back,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 5,
              backgroundColor: context.tokens.color.vsdslColorPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: context.tokens.radii.vsdslRadiusFull,
              ),
              padding: EdgeInsets.zero,
              shadowColor: context.tokens.color.vsdslColorPrimary,
            ),
          ),
        ),
        SizedBox(width: context.tokens.spacing.vsdslSpacingSm.top),
        SizedBox(
          width: 27,
          height: 27,
          child: IconButton(
            icon: const Image(
              image: Svg('assets/images/ic_participant_stop.svg'),
            ),
            style: IconButton.styleFrom(
              elevation: 10.0,
              shadowColor: context.tokens.color.vsdslColorOpacityNeutralXs,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              trackEvent('click_disconnect', EventCategory.castToBoards);

              if (!rtcConnector.isChannelConnectAvailable()) {
                rtcConnector.clickButtonWhenReconnect = true;
                V3Toast()
                    .makeReconnectToast(
                        rtcConnector.reconnectChannelState,
                        rtcConnector.reconnectChannelState ==
                                ReconnectState.reconnecting
                            ? S.of(context).main_feature_reconnecting_toast
                            : S.of(context).main_feature_reconnect_fail_toast)
                    ?.show(context);
                return;
              }
              rtcConnector.sendStopRemoteScreen();
              int index = channelProvider.remoteShareConnectors
                  .indexWhere((item) => item.clientId == rtcConnector.clientId);
              if (index != -1) {
                RemoteScreenConnector remoteShareConnector =
                    channelProvider.remoteShareConnectors[index];

                channelProvider.removeSender(
                  fromShare: true,
                  remoteScreenConnector: remoteShareConnector,
                  kick: false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  _touchBackOn(BuildContext context) {
    trackEvent('click_touchback', EventCategory.castToBoards, target: 'on');

    // find the remoteShareConnector with same clientId as rtcConnector.
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    int index = channelProvider.remoteShareConnectors
        .indexWhere((item) => item.clientId == rtcConnector.clientId);
    if (index != -1) {
      RemoteScreenConnector remoteShareConnector =
          channelProvider.remoteShareConnectors[index];

      remoteShareConnector.isTouchEnabled = true;
      channelProvider.remoteScreenServe.enableRemoteControlBySessionId(
          remoteShareConnector.sessionId!, remoteShareConnector.isTouchEnabled);
      callback?.call();
    }
  }
}

class ParticipantControllingFeature extends StatelessWidget {
  const ParticipantControllingFeature({
    super.key,
    required this.rtcConnector,
    this.callback,
  });

  final RTCConnector rtcConnector;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 27,
          height: 27,
          child: IconButton(
            icon: const Image(
              image: Svg('assets/images/ic_participant_stop.svg'),
            ),
            style: IconButton.styleFrom(
              elevation: 10.0,
              shadowColor: context.tokens.color.vsdslColorOpacityNeutralXs,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              _touchBackOff(context);
            },
          ),
        ),
      ],
    );
  }

  _touchBackOff(BuildContext context) {
    trackEvent('click_touchback', EventCategory.castToBoards, target: 'off');

    // find the remoteShareConnector with same clientId as rtcConnector.
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    int index = channelProvider.remoteShareConnectors
        .indexWhere((item) => item.clientId == rtcConnector.clientId);
    if (index != -1) {
      RemoteScreenConnector remoteShareConnector =
          channelProvider.remoteShareConnectors[index];

      remoteShareConnector.isTouchEnabled = false;
      channelProvider.remoteScreenServe.enableRemoteControlBySessionId(
          remoteShareConnector.sessionId!, remoteShareConnector.isTouchEnabled);
      callback?.call();
    }
  }
}
