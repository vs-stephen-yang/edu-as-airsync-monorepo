import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class V3QrcodeQuickConnect extends StatelessWidget {
  const V3QrcodeQuickConnect(
      {super.key, this.isStringOnTop = false, this.width = 130});

  final bool isStringOnTop;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: isStringOnTop ? 8 : null,
          bottom: isStringOnTop ? null : 20,
          child: AutoSizeText(
            S.of(context).v3_qrcode_quick_connect,
            style: TextStyle(
              color: context.tokens.color.vsdslColorNeutral,
              fontWeight: FontWeight.w600,
              fontSize: isStringOnTop ? 21 : 14,
            ),
          ),
        ),
        Image(
          width: width,
          image: const Svg('assets/images/ic_qrcode_background.svg'),
        ),
        Consumer2<InstanceInfoProvider, ChannelProvider>(
            builder: (_, instanceProvider, channelProvider, __) {
          // todo: design deep link to implement quick connect
          String quickConnectData =
              'Quick Connect: display code=${instanceProvider.displayCode}, otp=${channelProvider.otp.value}';
          return QrImageView(
            data: 'Not implement yet!!. $quickConnectData',
            version: QrVersions.auto,
            size: width - 20,
          );
        }),
      ],
    );
  }
}
