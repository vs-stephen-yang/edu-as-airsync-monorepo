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
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3StreamingFunction extends StatefulWidget {
  const V3StreamingFunction({super.key, required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => _V3StreamingFunctionState();
}

class _V3StreamingFunctionState extends State<V3StreamingFunction> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: HybridConnectionList().getConnectionCount() > 1 ? 101 : 74,
        height: 37,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.tokens.color.vsdslColorOpacityNeutralXl,
          borderRadius: context.tokens.radii.vsdslRadiusFull,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (HybridConnectionList().getConnectionCount() > 1)
              SizedBox(
                width: 27,
                child: IconButton(
                  icon: const Image(
                    image: Svg('assets/images/ic_streaming_resize.svg'),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    if (HybridConnectionList().isMirrorRequest(widget.index)) {
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
                      webrtcConnector.trackSessionEvent('click_screen_size');

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
            Consumer<MirrorStateProvider>(
              builder: (_, mirrorStateProvider, __) {
                var isMute = HybridConnectionList()
                    .getAudioDisableStateByIndex(widget.index);
                return SizedBox(
                  width: 27,
                  height: 27,
                  child: IconButton(
                    icon: Image(
                      image: isMute
                          ? const Svg('assets/images/ic_streaming_unmute.svg')
                          : const Svg('assets/images/ic_streaming_mute.svg'),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        HybridConnectionList().updateAudioEnableStateByIndex(
                            widget.index, isMute, true);
                      });
                    },
                  ),
                );
              },
            ),
            SizedBox(
              width: 27,
              height: 27,
              child: IconButton(
                icon: const Image(
                  image: Svg('assets/images/ic_streaming_stop.svg'),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (HybridConnectionList().isMirrorRequest(widget.index)) {
                    var connection = HybridConnectionList()
                        .getConnection<MirrorRequest>(widget.index);
                    if (connection.mirrorState == MirrorState.mirroring) {
                      HybridConnectionList().stopPresenterBy(widget.index);
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
                      HybridConnectionList().stopPresenterBy(widget.index);
                    } else {
                      SplitScreenFunction.isMenuOnList.value.fillRange(0,
                          SplitScreenFunction.isMenuOnList.value.length, false);
                      HybridConnectionList().removePresenterBy(widget.index);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
