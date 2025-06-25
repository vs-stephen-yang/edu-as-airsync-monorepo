import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/widgets/v3_broadcast_indicator.dart';
import 'package:display_flutter/widgets/v3_text_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3Status extends StatelessWidget {
  const V3Status({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Image(
          excludeFromSemantics: true,
          image: const Svg('assets/images/ic_screen.svg'),
          width: 27,
          height: 27,
          color: context.tokens.color.vsdslColorOnSurface,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.tokens.spacing.vsdslSpacingSm.left,
          ),
          child: Consumer<InstanceInfoProvider>(
            builder: (_, provider, __) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                // This is device name, should not use - to confuse user
                child: Text(
                  textAlign: TextAlign.center,
                  provider.deviceName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.tokens.color.vsdslColorOnSurface,
                  ),
                ),
              );
            },
          ),
        ),
        const V3BroadcastIndicator(),
        Consumer<ConnectivityProvider>(
          builder: (_, connectivityProvider, __) {
            String networkIconName;
            if (connectivityProvider.connectionStatus ==
                ConnectivityResult.wifi) {
              // todo: fine tune threshold 0~99.
              if (connectivityProvider.signalStrength >= 80) {
                networkIconName = 'ic_network_wifi_high.svg';
              } else if (connectivityProvider.signalStrength >= 30) {
                networkIconName = 'ic_network_wifi_middle.svg';
              } else {
                networkIconName = 'ic_network_wifi_low.svg';
              }
            } else if (connectivityProvider.connectionStatus ==
                ConnectivityResult.ethernet) {
              networkIconName = 'ic_network_ethernet.svg';
            } else {
              networkIconName = 'ic_network_disconnect.svg';
            }
            return Image(
              excludeFromSemantics: true,
              height: 27,
              width: 27,
              image: Svg('assets/images/$networkIconName'),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.tokens.spacing.vsdslSpacingLg.left,
          ),
          child: Container(
            width: 1,
            height: 27,
            color: context.tokens.color.vsdslColorOutlineVariant,
          ),
        ),
        const V3TextClock(),
      ],
    );
  }
}
