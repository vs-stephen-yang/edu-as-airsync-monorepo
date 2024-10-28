import 'dart:developer';

import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class V3QrCodeImage extends StatelessWidget {
  const V3QrCodeImage({
    super.key,
    this.isShowBackground = false,
    this.isStringOnTop = false,
    this.size = 139,
  });

  final bool isShowBackground;
  final bool isStringOnTop;
  final double size;

  @override
  Widget build(BuildContext context) {
    String appVersion = AppConfig.of(context)?.appVersion ?? '';
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isShowBackground)
          Image(
            width: size,
            height: size,
            image: Svg(isStringOnTop
                ? 'assets/images/ic_qrcode_background2.svg'
                : 'assets/images/ic_qrcode_background1.svg'),
          ),
        Consumer2<InstanceInfoProvider, ChannelProvider>(
          builder: (_, instanceProvider, channelProvider, __) {
            return ValueListenableBuilder<String>(
              valueListenable: channelProvider.otp,
              builder: (_, otp, __) {
                // todo: design deep link to implement quick connect
                final ver = appVersion.replaceAll('-', '_');
                final dc = instanceProvider.displayCode;
                final otp = channelProvider.otp.value;
                String quickConnectData =
                    'https://airsync/Quick_Connect?display_code=$dc&otp=$otp&ver=$ver';
                log('quickConnectData: $quickConnectData');
                return QrImageView(
                  data: quickConnectData,
                  version: QrVersions.auto,
                  padding: EdgeInsets.zero,
                  size: isShowBackground
                      ? isStringOnTop
                          ? size - 35
                          : size - 32
                      : size,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
