import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
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
  late ChannelProvider channelProvider;
  late RemoteScreenConnector remoteScreenConnector;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context);
    remoteScreenConnector = ChannelProvider.remoteScreenConnectors[widget.index];
    String presenterName = remoteScreenConnector.senderName ?? '';

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
                remoteScreenConnector.presentationState == PresentationState.streaming
                    ? AppColors.primary_blue
                    : AppColors.toggle_bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              showWhiteBorder: true,
              onClick: () {
                if (remoteScreenConnector.presentationState == PresentationState.streaming) {
                  channelProvider.removeSender(remoteScreenConnector:remoteScreenConnector);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    presenterName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: IconButton(
              icon: const Icon(Icons.touch_app),
              color: AppColors.toggle_bg, //remoteScreenConnector.presentationState == PresentationState.streaming? Colors.white:AppColors.toggle_bg,
              splashRadius: 20,
              onPressed: () {
                // TODO: 小控大
            },
            ),
          ),
        ],
      ),
    );
  }
}
