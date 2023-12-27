
import 'package:display_flutter/generated/l10n.dart';
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
    print('zz _ParticipantListViewState build');
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: channelProvider.channelRtcConnectors.isEmpty
          ? Container(
              alignment: Alignment.center,
              child: Text(
                S.of(context).moderator_presentersLimit,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : ListView.separated(
              itemCount: channelProvider.channelRtcConnectors.length,
              itemBuilder: (BuildContext context, int index) {
                if (index > 5) return const SizedBox();

                return ParticipantItem(index: index);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 0, color: Colors.transparent);
              },
            ),
    );
  }
}