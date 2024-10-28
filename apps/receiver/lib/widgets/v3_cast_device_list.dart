import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_cast_device_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3CastDeviceList extends StatelessWidget {
  const V3CastDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
      builder: (_, channelProvider, __) {
        return Column(
          children: [
            AutoSizeText.rich(
              TextSpan(children: [
                TextSpan(
                  text: S.of(context).v3_cast_to_device_title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurface,
                  ),
                ),
                TextSpan(
                  text:
                      ' (${channelProvider.remoteScreenConnectors.length}/${channelProvider.maxRemoteScreenConnection})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: context.tokens.color.vsdslColorOnSurface,
                  ),
                )
              ]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.tokens.spacing.vsdslSpacingXs.top),
            AutoSizeText(
              S.of(context).v3_cast_to_device_reached_maximum,
              style: TextStyle(
                fontSize: 12,
                color: channelProvider.remoteScreenConnectors.length ==
                        channelProvider.maxRemoteScreenConnection
                    ? context.tokens.color.vsdslColorWarning
                    : Colors.transparent,
              ),
            ),
            SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
            Expanded(
              child: ListView.separated(
                itemCount: channelProvider.remoteScreenConnectors.length,
                itemBuilder: (BuildContext context, int index) {
                  return V3CastDeviceItem(index: index);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: context.tokens.spacing.vsdslSpacingMd.top,
                    color: Colors.transparent,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
