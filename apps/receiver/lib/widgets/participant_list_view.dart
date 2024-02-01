
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/rtc_connector_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/participant_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantListView extends StatefulWidget {
  const ParticipantListView({super.key});

  @override
  State createState() => _ParticipantListViewState();
}

class _ParticipantListViewState extends State<ParticipantListView> {

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Consumer<ChannelProvider>(
        builder: (context, provider, child) {
          if (!ChannelProvider.isModeratorMode ||
              RtcConnectorList.rtcConnectorList.nonNulls.isEmpty) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                S.of(context).moderator_presentersLimit,
              ),
            );
          } else {
            return ListView.separated(
              itemCount: RtcConnectorList.rtcConnectorList.length,
              itemBuilder: (BuildContext context, int index) {
                if (index > 5 || RtcConnectorList.rtcConnectorList[index] == null) {
                  return const SizedBox.shrink();
                }
                return ParticipantItem(index: index);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 0, color: Colors.transparent);
              },
            );
          }
        },
      ),
    );
  }
}