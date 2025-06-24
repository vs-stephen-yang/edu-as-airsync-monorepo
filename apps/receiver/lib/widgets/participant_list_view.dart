import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/participant_item.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantListView extends StatelessWidget {
  const ParticipantListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Consumer<ChannelProvider>(
        builder: (context, channelProvider, child) {
          if (!ChannelProvider.isModeratorMode ||
              HybridConnectionList().getRtcConnectorMap().isEmpty) {
            return Container(
              alignment: Alignment.center,
              child: V3AutoHyphenatingText(
                S.of(context).moderator_presentersLimit,
              ),
            );
          } else {
            return ListView.separated(
              itemCount: HybridConnectionList().getConnectionCount(),
              itemBuilder: (BuildContext context, int index) {
                if (index > 5) {
                  return const SizedBox.shrink();
                }
                return ParticipantItem(
                    rtcConnector: HybridConnectionList()
                        .getRtcConnectorMap()
                        .values
                        .toList()[index]);
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
