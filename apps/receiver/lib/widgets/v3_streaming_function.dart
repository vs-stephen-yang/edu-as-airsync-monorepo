import 'dart:async';

import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/utility/toast.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:display_flutter/widgets/split_screen_function.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3StreamingFunction extends StatefulWidget {
  const V3StreamingFunction({super.key, required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => _V3StreamingFunctionState();
}

class _V3StreamingFunctionState extends State<V3StreamingFunction> {
  bool isCollapsed = false;
  Timer? autoCollapseTimer;

  @override
  void initState() {
    super.initState();
    _startAutoCollapseTimer();
  }

  @override
  void dispose() {
    autoCollapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isCollapsed ? EdgeInsets.zero : const EdgeInsets.only(bottom: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: isCollapsed
              ? 37
              : HybridConnectionList.hybridSplitScreenCount.value > 1
                  ? 140
                  : 106,
          height: isCollapsed ? 22 : 43,
        ),
        child: Container(
          padding: isCollapsed ? const EdgeInsets.only(top: 4) : null,
          decoration: BoxDecoration(
            color: context.tokens.color.vsdslColorOpacityNeutralXl
                .withOpacity(0.48),
            borderRadius: isCollapsed
                ? const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  )
                : context.tokens.radii.vsdslRadiusFull,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Use Visibility Widget to Maintain Focus on the Correct Icon During Collapse/Expand.
              Visibility(
                visible: !isCollapsed &&
                    HybridConnectionList.hybridSplitScreenCount.value > 1,
                child: V3Focus(
                  child: SizedBox(
                    width: 27,
                    height: 27,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        HybridConnectionList().enlargedScreenIndex.value ==
                                widget.index
                            ? 'assets/images/ic_streaming_collapse.svg'
                            : 'assets/images/ic_streaming_expand.svg',
                      ),
                      focusColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _startAutoCollapseTimer();
                        if (HybridConnectionList()
                            .isMirrorRequest(widget.index)) {
                          var connection = HybridConnectionList()
                              .getConnection<MirrorRequest>(widget.index);
                          if (connection.mirrorState == MirrorState.mirroring) {
                            _updateSizeForSelected(widget.index);
                            return;
                          }
                        }
                        var webrtcConnector = HybridConnectionList()
                            .getConnection<RTCConnector>(widget.index);
                        if (webrtcConnector.isChannelConnectAvailable()) {
                          webrtcConnector
                              .trackSessionEvent('click_screen_size');

                          _updateSizeForSelected(widget.index);
                        } else if (webrtcConnector.isChannelReconnect()) {
                          webrtcConnector.clickButtonWhenReconnect = true;
                          Toast.showSplitScreenReconnectToast(
                              context,
                              S.of(context).main_feature_reconnecting_toast,
                              widget.index,
                              isWebRTC: false,
                              state: webrtcConnector.reconnectChannelState);
                        } else {
                          V3Toast().makeSplitScreenReconnectToast(
                              context,
                              S.of(context).main_feature_reconnect_fail_toast,
                              widget.index,
                              isWebRTC: false,
                              state: webrtcConnector.reconnectChannelState);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !isCollapsed,
                child: Consumer<MirrorStateProvider>(
                  builder: (_, mirrorStateProvider, __) {
                    var isMute = HybridConnectionList()
                        .getAudioDisableStateByIndex(widget.index);
                    return V3Focus(
                      child: SizedBox(
                        width: 27,
                        height: 27,
                        child: IconButton(
                          icon: SvgPicture.asset(
                            isMute
                                ? 'assets/images/ic_streaming_unmute.svg'
                                : 'assets/images/ic_streaming_mute.svg',
                          ),
                          focusColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _startAutoCollapseTimer();

                            setState(() {
                              HybridConnectionList()
                                  .updateAudioEnableStateByIndex(
                                      widget.index, isMute, true);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Visibility(
                visible: !isCollapsed,
                child: V3Focus(
                  child: SizedBox(
                    width: 27,
                    height: 27,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/ic_streaming_stop.svg',
                      ),
                      focusColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (HybridConnectionList()
                            .isMirrorRequest(widget.index)) {
                          var connection = HybridConnectionList()
                              .getConnection<MirrorRequest>(widget.index);
                          if (connection.mirrorState == MirrorState.mirroring) {
                            HybridConnectionList()
                                .stopPresenterBy(widget.index);
                            return;
                          }
                        }
                        RTCConnector webrtcConnector = HybridConnectionList()
                            .getConnection<RTCConnector>(widget.index);
                        if (webrtcConnector.isChannelReconnect()) {
                          webrtcConnector.clickButtonWhenReconnect = true;
                          V3Toast().makeSplitScreenReconnectToast(
                              context,
                              S.of(context).main_feature_reconnecting_toast,
                              widget.index,
                              isWebRTC: false,
                              state: webrtcConnector.reconnectChannelState);
                        } else {
                          webrtcConnector.trackSessionEvent('stop_cast');

                          if (ChannelProvider.isModeratorMode) {
                            HybridConnectionList()
                                .stopPresenterBy(widget.index);
                          } else {
                            SplitScreenFunction.isMenuOnList.value.fillRange(
                                0,
                                SplitScreenFunction.isMenuOnList.value.length,
                                false);
                            HybridConnectionList()
                                .removePresenterBy(widget.index);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              V3Focus(
                child: SizedBox(
                  width: 27,
                  height: 27,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      isCollapsed
                          ? 'assets/images/ic_expend.svg'
                          : 'assets/images/ic_minimize.svg',
                      semanticsLabel: isCollapsed ? 'Expand' : 'Minimize',
                    ),
                    focusColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _toggleCollapse();
                      if (isCollapsed) {
                        autoCollapseTimer?.cancel();
                      } else {
                        _startAutoCollapseTimer();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startAutoCollapseTimer() {
    autoCollapseTimer?.cancel();
    autoCollapseTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        isCollapsed = true;
      });
    });
  }

  void _toggleCollapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  _updateSizeForSelected(int selection) {
    if (selection == HybridConnectionList().enlargedScreenIndex.value) {
      HybridConnectionList().enlargedScreenIndex.value = null;
    } else {
      HybridConnectionList().enlargedScreenIndex.value = selection;
    }
    HybridConnectionList().setSpecifiedSplitScreenWindowQuality(selection,
        HybridConnectionList().enlargedScreenIndex.value == selection);
  }
}
