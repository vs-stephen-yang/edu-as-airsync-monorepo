import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_participant_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3ParticipantList extends StatelessWidget {
  const V3ParticipantList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
      builder: (context, channelProvider, child) {
        if (!ChannelProvider.isModeratorMode ||
            HybridConnectionList().getRtcConnectorMap().isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 126,
                height: 110,
                child: Image(
                  image: Svg(ChannelProvider.isModeratorMode
                      ? 'assets/images/ic_moderator_people.svg'
                      : 'assets/images/ic_moderator_screen.svg'),
                ),
              ),
              AutoSizeText(
                S.of(context).v3_participants_desc,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.tokens.color.vsdslColorSurface400,
                ),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AutoSizeText.rich(
                TextSpan(children: [
                  TextSpan(
                    text: S.of(context).v3_participants_title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.color.vsdslColorOnSurface,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' (${HybridConnectionList().getRtcConnectorMap().length}/${HybridConnectionList.maxHybridConnection})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: context.tokens.color.vsdslColorOnSurface,
                    ),
                  )
                ]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: HybridConnectionList().getConnectionCount(),
                  itemBuilder: (BuildContext context, int index) {
                    return V3ParticipantItem(index: index);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 13, color: Colors.transparent);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
