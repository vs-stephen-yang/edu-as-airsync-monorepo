import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_icons_icons.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantItem extends StatefulWidget {
  const ParticipantItem({super.key, required this.index});

  final int index;

  @override
  State createState() => _ParticipantItemState();
}

class _ParticipantItemState extends State<ParticipantItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late ChannelProvider channelProvider;
  late RTCConnector rtcConnector;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('zz build _ParticipantItemState ${widget.index}');
    channelProvider = Provider.of<ChannelProvider>(context);
    rtcConnector = channelProvider.channelRtcConnectors[widget.index];
    String presenterId = rtcConnector.clientId!;
    String presenterName = rtcConnector.senderName!;

    if (presenterName.length > 10) {
      presenterName = '${presenterName.substring(0, 10)}..';
    }

    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: FocusElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                channelProvider.isPresenterStreaming(presenterId)
                    ? AppColors.primary_blue
                    : AppColors.toggle_bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              showWhiteBorder: true,
              onClick: () {
                _controller.repeat(reverse: false);
                _presenterOnOff(presenterId);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    presenterName,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Visibility(
                    visible:
                    channelProvider.isPresenterWaitForStream(presenterId),
                    child: RotationTransition(
                      turns: _animation,
                      child: const Icon(
                        CustomIcons.loading,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: FocusIconButton(
              childHasFocus: const CircleAvatar(
                backgroundColor: Color.fromRGBO(0x89, 0x89, 0x89, 1),
                child: Icon(Icons.delete, color: Colors.red),
              ),
              childNotFocus: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.delete, color: Colors.red),
              ),
              splashRadius: 20,
              focusColor: Colors.white,
              onClick: () {
                _sendPresenterRemove();
              },
            ),
          ),
        ],
      ),
    );
  }

  _presenterOnOff(String presenterId) async {
    if (channelProvider.isPresenterNotStopStreaming(presenterId)) {
      // waitForStream and streaming
      print('zz _presenterOnOff 6 $presenterId');
      _sendPresenterStop();
    } else {
      // occupied and stopStreaming
      print('zz _presenterOnOff 1 $presenterId');
      if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
        print('zz _presenterOnOff 2 $presenterId');
        if (!channelProvider.occupyAvailableRTCConnector()) {
          print('zz _presenterOnOff 3 $presenterId');
          return;
        }
      } else {
        print('zz _presenterOnOff 4 $presenterId');
        // Remove all other presenters before send Play for Quick switch.
        await channelProvider.removeOtherPresenters(keepInList: ChannelProvider.isModeratorMode);
      }
      print('zz _presenterOnOff 5 $presenterId');
      _sendPresenterPlay();
    }
  }

  _sendPresenterPlay() {
    print('zz _sendPresenterPlay');
    AppAnalytics().trackEventModeratorPresenterPresent();
    rtcConnector.sendAllowPresent();
  }

  _sendPresenterStop() {
    print('zz _sendPresenterStop');
    AppAnalytics().trackEventModeratorPresenterStop();
    rtcConnector.sendStopPresent();
  }

  _sendPresenterRemove() async {
    print('zz _sendPresenterRemove');
    AppAnalytics().trackEventModeratorPresentersRemove();
    await rtcConnector.disconnectPeerConnection();
    rtcConnector.onChannelDisconnect?.call();
  }
}
