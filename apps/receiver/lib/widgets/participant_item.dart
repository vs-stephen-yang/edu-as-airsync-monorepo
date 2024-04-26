import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/loading_icon.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class ParticipantItem extends StatelessWidget {
  const ParticipantItem({super.key, required this.rtcConnector});

  final RTCConnector rtcConnector;

  @override
  Widget build(BuildContext context) {
    String presenterId = rtcConnector.clientId ?? '';
    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: FocusElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    HybridConnectionList().isPresenterStreaming(presenterId)
                        ? AppColors.primary_blue
                        : AppColors.toggle_bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              showWhiteBorder: true,
              onClick: () {
                _presenterOnOff(context, rtcConnector, presenterId);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    rtcConnector.senderNameWithEllipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Visibility(
                    visible: HybridConnectionList()
                        .isPresenterWaitForStream(presenterId),
                    child: const LoadingIcon(),
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
                _sendPresenterRemove(rtcConnector);
              },
            ),
          ),
        ],
      ),
    );
  }

  _presenterOnOff(
      BuildContext context, RTCConnector rtcConnector, String presenterId) {
    if (HybridConnectionList().isPresenterNotStopStreaming(presenterId)) {
      // waitForStream and streaming
      _sendPresenterStop(rtcConnector);
    } else {
      if (HybridConnectionList().getPresentingCount() >= 4) {
        MotionToast(
          primaryColor: Colors.grey,
          backgroundType: BackgroundType.solid,
          description: AutoSizeText(
            S.of(context).toast_maximum_split_screen,
            maxLines: 1,
          ),
          displaySideBar: false,
        ).show(context);
        return;
      }
      _sendPresenterPlay(rtcConnector);
    }
  }

  _sendPresenterPlay(RTCConnector rtcConnector) {
    AppAnalytics().trackEventModeratorPresenterPresent();
    rtcConnector.sendAllowPresent();
  }

  _sendPresenterStop(RTCConnector rtcConnector) {
    AppAnalytics().trackEventModeratorPresenterStop();
    rtcConnector.sendStopPresent();
  }

  _sendPresenterRemove(RTCConnector rtcConnector) async {
    AppAnalytics().trackEventModeratorPresentersRemove();
    await rtcConnector.disconnectPeerConnection();
    await rtcConnector.disconnectChannel();
  }
}
