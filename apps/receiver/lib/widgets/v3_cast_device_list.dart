import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_cast_device_item.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3CastDeviceList extends StatelessWidget {
  const V3CastDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
      builder: (_, channelProvider, __) {
        final ScrollController scrollController = ScrollController();
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
            if (channelProvider.remoteScreenConnectors.length ==
                channelProvider.maxRemoteScreenConnection)
              AutoSizeText(
                S.of(context).v3_cast_to_device_reached_maximum,
                style: TextStyle(
                    fontSize: 12,
                    color: context.tokens.color.vsdslColorWarning),
              ),
            SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
            Expanded(
              child: channelProvider.remoteScreenConnectors.isNotEmpty
                  ? V3Scrollbar(
                      controller: scrollController,
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount:
                            channelProvider.remoteScreenConnectors.length,
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
                    )
                  : const Center(
                      child: DeviceEmpty(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class DeviceEmpty extends StatelessWidget {
  const DeviceEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/ic_csat_device_empty.svg',
          excludeFromSemantics: true,
          width: 126,
          height: 110,
        ),
        const Gap(13),
        Text(
          S.of(context).v3_cast_to_device_list_msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.tokens.color.vsdslColorOnSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
