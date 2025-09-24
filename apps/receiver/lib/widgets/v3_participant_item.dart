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
import 'package:display_flutter/widgets/text_size_aware.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final v3Toast = context.read<V3Toast>();

    final RTCConnector rtcConnector =
        HybridConnectionList().getConnection<RTCConnector>(widget.index);
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
          Provider.of<ChannelProvider>(context, listen: true);
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
          if (!mounted) return;
          setState(() {});
        },
      );
    } else if (isReceiving) {
      status = S.of(context).v3_participant_item_receiving;
      itemParticipant = ParticipantReceivingFeature(
        rtcConnector: rtcConnector,
        callback: () {
          if (!mounted) return;
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

    return Container(
      alignment: Alignment.center,
      width: widget.isForMenuUse ? 358 : 283,
      child: Row(
        children: [
          SvgPicture.asset(
            isCasting
                ? 'assets/images/ic_participant_avatar_cast.svg'
                : isReceiving
                    ? 'assets/images/ic_participant_avatar_receive.svg'
                    : 'assets/images/ic_participant_avatar_wait.svg',
            excludeFromSemantics: true,
            width: 32,
            height: 32,
          ),
          Gap(context.tokens.spacing.vsdslSpacingSm.left),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  constraints: BoxConstraints(minHeight: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        rtcConnector.senderName ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.tokens.color.vsdslColorOnSurface,
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
                                ? context
                                    .tokens.color.vsdslColorOnSurfaceVariant
                                : (isCasting)
                                    ? context
                                        .tokens.color.vsdslColorSecondaryVariant
                                    : context
                                        .tokens.color.vsdslColorSuccessVariant,
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
              ],
            ),
          ),
          if (!isWaiting & !isCasting & !isReceiving & !isControlling)
            V3Focus(
              label: S.of(context).v3_lbl_participant_close,
              identifier: 'v3_qa_participant_close',
              child: SizedBox(
                width: 27,
                height: 27,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/ic_participant_close.svg',
                    excludeFromSemantics: true,
                  ),
                  style: IconButton.styleFrom(
                    elevation: 10.0,
                    shadowColor:
                        context.tokens.color.vsdslColorOpacityNeutralXs,
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
          ValueListenableBuilder(
            valueListenable: rtcConnector.reconnectChannelStateNotifier,
            builder:
                (BuildContext context, ReconnectState value, Widget? child) {
              if (rtcConnector.clickButtonWhenReconnect) {
                if (value == ReconnectState.success) {
                  rtcConnector.clickButtonWhenReconnect = false;
                  v3Toast
                      .makeReconnectToast(value,
                          S.of(context).main_feature_reconnect_success_toast)
                      ?.show(context);
                  rtcConnector.reconnectChannelStateNotifier.value =
                      ReconnectState.idle;
                } else if (value == ReconnectState.fail) {
                  rtcConnector.clickButtonWhenReconnect = false;
                  v3Toast
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

  _sendPresenterRemove(BuildContext context, RTCConnector rtcConnector) async {
    final v3Toast = context.read<V3Toast>();

    if (widget.isForMenuUse) {
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
      v3Toast
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

class ParticipantStandbyFeature extends TextSizeAwareStateless {
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
  Widget buildWithTextSize(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        V3Focus(
          label: S.of(context).v3_lbl_participant_share,
          identifier: 'v3_qa_participant_share',
          child: SizedBox(
            height: 27,
            child: showIcon
                ? InkWell(
                    onTap: () {
                      EasyThrottle.throttle(
                          'presenterOn', const Duration(seconds: 1), () {
                        _presenterOn(context, rtcConnector, presenterId);
                      });
                    },
                    child: SvgPicture.asset(
                      'assets/images/ic_moderator_share.svg',
                      width: 26,
                      height: 26,
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      shadowColor:
                          context.tokens.color.vsdslColorOpacitySecondaryLg,
                      backgroundColor: context.tokens.color.vsdslColorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: context.tokens.radii.vsdslRadiusFull,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () {
                      EasyThrottle.throttle(
                          'presenterOn', const Duration(seconds: 1), () {
                        _presenterOn(context, rtcConnector, presenterId);
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isForMenuUse) ...[
                          SizedBox(
                            child: SvgPicture.asset(
                              'assets/images/ic_arrow_to_screen.svg',
                              excludeFromSemantics: true,
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                  context
                                      .tokens.color.vsdslColorOnSurfaceInverse,
                                  BlendMode.srcIn),
                            ),
                          ),
                          Gap(context.tokens.spacing.vsdslSpacingXs.left),
                        ],
                        V3AutoHyphenatingText(
                          S.of(context).v3_participant_item_share,
                          textAlign:
                              isForMenuUse ? TextAlign.left : TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (isForMenuUse && rtcConnector.senderPlatform != 'web') ...[
          Gap(context.tokens.spacing.vsdslSpacingSm.left),
          V3Focus(
            label: S.of(context).v3_lbl_participant_cast_device,
            identifier: 'v3_qa_participant_cast_device',
            child: SizedBox(
              width: 27,
              height: 27,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/ic_participant_cast_device.svg',
                  excludeFromSemantics: true,
                  width: 16,
                  height: 16,
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
      ],
    );
  }

  _presenterOn(
      BuildContext context, RTCConnector rtcConnector, String presenterId) {
    final v3Toast = context.read<V3Toast>();

    if (!rtcConnector.isChannelConnectAvailable()) {
      rtcConnector.clickButtonWhenReconnect = true;
      v3Toast
          .makeReconnectToast(
              rtcConnector.reconnectChannelState,
              rtcConnector.reconnectChannelState == ReconnectState.reconnecting
                  ? S.of(context).main_feature_reconnecting_toast
                  : S.of(context).main_feature_reconnect_fail_toast)
          ?.show(context);
      return;
    }
    if (HybridConnectionList()
        .isPresenterStopStreaming(clientId: presenterId)) {
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
    final v3Toast = context.read<V3Toast>();

    if (!rtcConnector.isChannelConnectAvailable()) {
      rtcConnector.clickButtonWhenReconnect = true;
      v3Toast
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
}

class ParticipantStreamingFeature extends TextSizeAwareStateless {
  const ParticipantStreamingFeature({
    super.key,
    required this.rtcConnector,
    required this.presenterId,
  });

  final RTCConnector rtcConnector;
  final String presenterId;

  @override
  Widget buildWithTextSize(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        V3Focus(
          label: S.of(context).v3_lbl_participant_stop,
          identifier: 'v3_qa_participant_stop',
          child: SizedBox(
            width: 27,
            height: 27,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/ic_participant_stop.svg',
                excludeFromSemantics: true,
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
    final v3Toast = context.read<V3Toast>();

    if (!rtcConnector.isChannelConnectAvailable()) {
      rtcConnector.clickButtonWhenReconnect = true;
      v3Toast
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
    rtcConnector.trackSessionEvent('stop_cast');
  }
}

class ParticipantReceivingFeature extends TextSizeAwareStateless {
  const ParticipantReceivingFeature({
    super.key,
    required this.rtcConnector,
    this.callback,
  });

  final RTCConnector rtcConnector;
  final VoidCallback? callback;

  @override
  Widget buildWithTextSize(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: [
        if (channelProvider.remoteScreenServe.supportTouchEvent) ...[
          V3Focus(
            label: S.of(context).v3_lbl_participant_touch_back,
            identifier: 'v3_qa_participant_touch_back',
            child: SizedBox(
              height: 27,
              child: showIcon
                  ? InkWell(
                      onTap: () {
                        EasyThrottle.throttle(
                            'touchBackOn', const Duration(seconds: 1), () {
                          _touchBackOn(context);
                        });
                      },
                      child: SvgPicture.asset(
                        'assets/images/ic_moderator_touchback.svg',
                        width: 26,
                        height: 26,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        EasyThrottle.throttle(
                            'touchBackOn', const Duration(seconds: 1), () {
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        shadowColor:
                            context.tokens.color.vsdslColorOnSurfaceInverse,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/ic_finger_touch.svg',
                            excludeFromSemantics: true,
                            width: 16,
                            height: 16,
                          ),
                          Gap(context.tokens.spacing.vsdslSpacingXs.left),
                          V3AutoHyphenatingText(
                            S.of(context).v3_cast_to_device_touch_back,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.tokens.color.vsdslColorOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Gap(context.tokens.spacing.vsdslSpacingSm.top),
        ],
        V3Focus(
          label: S.of(context).v3_lbl_participant_disconnect,
          identifier: 'v3_qa_participant_disconnect',
          child: SizedBox(
            width: 27,
            height: 27,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/ic_participant_stop.svg',
                excludeFromSemantics: true,
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

    final v3Toast = context.read<V3Toast>();

    if (!rtcConnector.isChannelConnectAvailable()) {
      rtcConnector.clickButtonWhenReconnect = true;
      v3Toast
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

class ParticipantControllingFeature extends TextSizeAwareStateless {
  const ParticipantControllingFeature({
    super.key,
    required this.rtcConnector,
    this.callback,
  });

  final RTCConnector rtcConnector;
  final VoidCallback? callback;

  @override
  Widget buildWithTextSize(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);

    final v3Toast = context.read<V3Toast>();

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: [
        V3Focus(
          label: S.of(context).v3_lbl_participant_touch_back_disable,
          identifier: 'v3_qa_participant_touch_back_disable',
          child: SizedBox(
            height: 27,
            child: showIcon
                ? InkWell(
                    onTap: () {
                      _touchBackOff(context);
                    },
                    child: SvgPicture.asset(
                      'assets/images/ic_moderator_untouchback.svg',
                      width: 26,
                      height: 26,
                    ),
                  )
                : ElevatedButton(
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
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      shadowColor:
                          context.tokens.color.vsdslColorOnSurfaceInverse,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_finger_disable.svg',
                          excludeFromSemantics: true,
                          width: 16,
                          height: 16,
                        ),
                        Gap(context.tokens.spacing.vsdslSpacingXs.left),
                        V3AutoHyphenatingText(
                          S.of(context).v3_cast_to_device_touch_back_disable,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.tokens.color.vsdslColorError,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        Gap(context.tokens.spacing.vsdslSpacingSm.top),
        V3Focus(
          label: S.of(context).v3_lbl_participant_disconnect,
          identifier: 'v3_qa_participant_disconnect',
          child: SizedBox(
            width: 27,
            height: 27,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/ic_participant_stop.svg',
                excludeFromSemantics: true,
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
                  v3Toast
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
