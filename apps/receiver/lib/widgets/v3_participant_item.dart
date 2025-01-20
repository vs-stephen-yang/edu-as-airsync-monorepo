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
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
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
    bool isWaiting = ((rtcConnector.presentationState.index) ==
        PresentationState.waitForStream.index);
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
    } else if (isWaiting) {
      status = S.of(context).v3_participant_item_waiting;
      itemParticipant = const SizedBox.shrink();
    } else {
      itemParticipant = ParticipantStandbyFeature(
        rtcConnector: rtcConnector,
        presenterId: presenterId,
        isForMenuUse: widget.isForMenuUse,
      );
    }

    return SizedBox(
      width: widget.isForMenuUse ? 358 : 283,
      height: 34,
      child: Row(
        children: [
          Image(
            width: 32,
            height: 32,
            image: Svg(isCasting
                ? 'assets/images/ic_participant_avatar_cast.svg'
                : isReceiving
                    ? 'assets/images/ic_participant_avatar_receive.svg'
                    : 'assets/images/ic_participant_avatar_wait.svg'),
          ),
          Gap(context.tokens.spacing.vsdslSpacingSm.left),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
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
                  Gap(context.tokens.spacing.vsdslSpacingXs.top),
                  AutoSizeText(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: (isWaiting)
                          ? context.tokens.color.vsdslColorSurface400
                          : (isCasting)
                              ? context.tokens.color.vsdslColorSecondary
                              : context.tokens.color.vsdslColorSuccess,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 8,
                  ),
                ],
              ],
            ),
          ),
          Gap(context.tokens.spacing.vsdslSpacing2xl.left),
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
        V3Focus(
          child: SizedBox(
            width: isForMenuUse
                ? rtcConnector.senderPlatform == 'web'
                    ? 105
                    : 74
                : 66,
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
                EasyThrottle.throttle('presenterOn', const Duration(seconds: 1),
                    () {
                  _presenterOn(context, rtcConnector, presenterId);
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isForMenuUse) ...[
                    Gap(context.tokens.spacing.vsdslSpacingSm.left),
                    SizedBox(
                      child: Image(
                        width: 16,
                        height: 16,
                        image:
                            const Svg('assets/images/ic_arrow_to_screen.svg'),
                        color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      ),
                    ),
                    Gap(context.tokens.spacing.vsdslSpacingXs.left),
                  ],
                  Expanded(
                    child: Text(
                      S.of(context).v3_participant_item_share,
                      textAlign:
                          isForMenuUse ? TextAlign.left : TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap(context.tokens.spacing.vsdslSpacingSm.left),
        if (isForMenuUse && rtcConnector.senderPlatform != 'web') ...[
          V3Focus(
            child: SizedBox(
              width: 27,
              height: 27,
              child: IconButton(
                icon: const Image(
                  width: 16,
                  height: 16,
                  image: Svg('assets/images/ic_participant_cast_device.svg'),
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
                  EasyThrottle.throttle(
                      'sendInviteRemoteScreen', const Duration(seconds: 1), () {
                    _sendInviteRemoteScreen(context, rtcConnector);
                  });
                },
              ),
            ),
          ),
          SizedBox(width: context.tokens.spacing.vsdslSpacingSm.left),
        ],
        V3Focus(
          child: SizedBox(
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
                EasyThrottle.throttle(
                    'sendPresenterRemove', const Duration(seconds: 1), () {
                  _sendPresenterRemove(context, rtcConnector);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  _presenterOn(
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
    if (HybridConnectionList().isPresenterStopStreaming(presenterId)) {
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

  _sendInviteRemoteScreen(BuildContext context, RTCConnector rtcConnector) {
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
    rtcConnector.sendInviteRemoteScreen();
  }

  _sendPresenterRemove(BuildContext context, RTCConnector rtcConnector) async {
    if (isForMenuUse) {
      trackEvent(
        'click_exit',
        EventCategory.session,
        participatorId: rtcConnector.clientId,
        mode: 'webrtc',
      );
    }
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
        V3Focus(
          child: SizedBox(
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
                EasyThrottle.throttle(
                    'presenterOff', const Duration(seconds: 1), () {
                  _presenterOff(context, rtcConnector, presenterId);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  _presenterOff(
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
        V3Focus(
          child: SizedBox(
            width: 104,
            height: 27,
            child: ElevatedButton(
              onPressed: () {
                EasyThrottle.throttle('touchBackOn', const Duration(seconds: 1),
                    () {
                  _touchBackOn(context);
                });
              },
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor:
                    context.tokens.color.vsdslColorOnSurfaceInverse,
                shape: RoundedRectangleBorder(
                  borderRadius: context.tokens.radii.vsdslRadiusFull,
                ),
                padding: EdgeInsets.zero,
                shadowColor: context.tokens.color.vsdslColorOnSurfaceInverse,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(context.tokens.spacing.vsdslSpacingSm.left),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: Image(
                      image: Svg('assets/images/ic_finger_touch.svg'),
                    ),
                  ),
                  Gap(context.tokens.spacing.vsdslSpacingXs.left),
                  Expanded(
                    child: Text(
                      S.of(context).v3_cast_to_device_touch_back,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap(context.tokens.spacing.vsdslSpacingSm.top),
        V3Focus(
          child: SizedBox(
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
                EasyThrottle.throttle('disconnect', const Duration(seconds: 1),
                    () {
                  _disconnect(context, channelProvider);
                });
              },
            ),
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

  _disconnect(BuildContext context, ChannelProvider channelProvider) {
    trackEvent('click_disconnect', EventCategory.castToBoards);

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
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    return Row(
      children: [
        V3Focus(
          child: SizedBox(
            width: 104,
            height: 27,
            child: ElevatedButton(
              onPressed: () {
                _touchBackOff(context);
              },
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor:
                    context.tokens.color.vsdslColorOnSurfaceInverse,
                shape: RoundedRectangleBorder(
                  borderRadius: context.tokens.radii.vsdslRadiusFull,
                ),
                padding: EdgeInsets.zero,
                shadowColor: context.tokens.color.vsdslColorOnSurfaceInverse,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(context.tokens.spacing.vsdslSpacingSm.left),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: Image(
                      image: Svg('assets/images/ic_finger_disable.svg'),
                    ),
                  ),
                  Gap(context.tokens.spacing.vsdslSpacingXs.left),
                  Expanded(
                    child: Text(
                      S.of(context).v3_cast_to_device_touch_back_disable,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap(context.tokens.spacing.vsdslSpacingSm.top),
        V3Focus(
          child: SizedBox(
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
                int index = channelProvider.remoteShareConnectors.indexWhere(
                    (item) => item.clientId == rtcConnector.clientId);
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
