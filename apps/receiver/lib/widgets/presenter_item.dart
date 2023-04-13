import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/display_info.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_icons_icons.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';

class PresenterItem extends StatefulWidget {
  const PresenterItem({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  State createState() => _PresenterItemState();
}

class _PresenterItemState extends State<PresenterItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

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
    String presenterId = DisplayInfo().peerList[widget.index].id;
    String presenterName =
        DisplayInfo().peerList[widget.index].presenter.replaceAll('\n', ' ');
    dynamic peer = DisplayInfo().peerList[widget.index].peer;

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
                    ControlSocket().isPresenterStreaming(presenterId)
                        ? AppColors.primary_blue
                        : AppColors.toggle_bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              showWhiteBorder: true,
              onClick: () {
                _controller.repeat(reverse: false);
                _presenterOnOff(presenterId, peer);
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
                        ControlSocket().isPresenterWaitForStream(presenterId),
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
                _sendPresenterRemove(peer);
              },
            ),
          ),
        ],
      ),
    );
  }

  _presenterOnOff(String presenterId, dynamic peer) async {
    if (!(ControlSocket().isPresenterNotStopStreaming(presenterId))) {
      if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
        if (!ControlSocket().occupyAvailableWebRTCViewController()) {
          return;
        }
      } else {
        // Remove all other presenters before send Play for Quick switch.
        await ControlSocket().removeAllPresenters();
      }
      _sendPresenterPlay(peer);
    } else {
      _sendPresenterStop(peer);
    }
  }

  _sendPresenterPlay(dynamic peer) {
    AppAnalytics().trackEventModeratorPresenterPresent();
    moderatorSocket.peerAction('play', peer, DisplayInfo().displayResponse);
  }

  _sendPresenterStop(dynamic peer) {
    AppAnalytics().trackEventModeratorPresenterStop();
    moderatorSocket.peerAction('stop', peer, DisplayInfo().displayResponse);
  }

  _sendPresenterRemove(dynamic peer) {
    AppAnalytics().trackEventModeratorPresentersRemove();
    moderatorSocket.peerAction('remove', peer, DisplayInfo().displayResponse);
  }
}
