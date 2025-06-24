import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SenderItem extends StatefulWidget {
  const SenderItem({super.key, required this.index, required this.editMode});

  final int index;
  final bool editMode;

  @override
  State createState() => _SenderItemState();
}

class _SenderItemState extends State<SenderItem>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    RemoteScreenConnector remoteScreenConnector =
        channelProvider.remoteScreenConnectors[widget.index];
    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: FocusElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    remoteScreenConnector.remotePresentationState ==
                            RemotePresentationState.streaming
                        ? AppColors.primaryBlue
                        : AppColors.toggleBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              showWhiteBorder: true,
              onClick: () {
                if (remoteScreenConnector.remotePresentationState ==
                    RemotePresentationState.streaming) {
                  channelProvider.removeSender(
                    fromSender: true,
                    remoteScreenConnector: remoteScreenConnector,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  V3AutoHyphenatingText(
                    remoteScreenConnector.senderNameWithEllipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: FocusIconButton(
              icons: Icons.touch_app,
              iconForegroundColor: remoteScreenConnector.isTouchEnabled
                  ? Colors.white
                  : AppColors.toggleBg,
              focusColor: Colors.grey,
              splashRadius: 20,
              onClick: () {
                remoteScreenConnector.isTouchEnabled =
                    !remoteScreenConnector.isTouchEnabled;
                channelProvider.remoteScreenServe
                    .enableRemoteControlBySessionId(
                        remoteScreenConnector.sessionId!,
                        remoteScreenConnector.isTouchEnabled);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
