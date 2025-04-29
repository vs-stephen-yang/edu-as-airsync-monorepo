import 'dart:developer';

import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          SvgPicture.asset(
            isStringOnTop
                ? 'assets/images/ic_qrcode_background2.svg'
                : 'assets/images/ic_qrcode_background1.svg',
            excludeFromSemantics: true,
            width: size,
            height: size,
          ),
        Consumer2<InstanceInfoProvider, ChannelProvider>(
          builder: (_, instanceProvider, channelProvider, __) {
            return ValueListenableBuilder<String>(
              valueListenable: channelProvider.otp,
              builder: (_, otp, __) {
                final ver = appVersion.replaceAll('-', '_');
                final dc = instanceProvider.displayCode;
                final otp = channelProvider.otp.value;
                String quickConnectData =
                    "${AppConfig.of(context)!.settings.appStoreUrl}?quick_connect=$dc@$otp@$ver";
                log('quickConnectData: $quickConnectData');
                return QrImageView(
                  data: quickConnectData,
                  version: QrVersions.auto,
                  padding: EdgeInsets.zero,
                  size: isShowBackground
                      ? isStringOnTop
                          ? size - 35
                          : size - 40
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
