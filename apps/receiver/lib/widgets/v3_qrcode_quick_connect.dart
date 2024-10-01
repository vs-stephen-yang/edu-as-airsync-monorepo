import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class V3QrcodeQuickConnect extends StatelessWidget {
  const V3QrcodeQuickConnect(
      {super.key, this.isStringOnTop = false, this.size = 139});

  final bool isStringOnTop;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget title = AutoSizeText(
      S.of(context).v3_qrcode_quick_connect,
      style: TextStyle(
        color: context.tokens.color.vsdslColorNeutral,
        fontWeight: FontWeight.w600,
        fontSize: isStringOnTop ? 21 : 14,
      ),
    );

    Widget space = SizedBox(
        height: isStringOnTop
            ? context.tokens.spacing.vsdslSpacing3xl.top - 1
            : context.tokens.spacing.vsdslSpacingXl.top - 1);

    PackageInfo? pkgInfo;
    Widget qrCode = StatefulBuilder(builder: (context, setState) {
      if (pkgInfo == null) {
        PackageInfo.fromPlatform().then((packageInfo) {
          setState(() {
            pkgInfo = packageInfo;
          });
        });
      }
      return Stack(
        alignment: Alignment.center,
        children: [
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
                  final ver = (pkgInfo?.version ?? '').replaceAll('-', '_');
                  final dc = instanceProvider.displayCode;
                  final otp = channelProvider.otp.value;
                  String quickConnectData =
                      'https://airsync/Quick_Connect?display_code=$dc&otp=$otp&ver=$ver';
                  return QrImageView(
                    data: quickConnectData,
                    version: QrVersions.auto,
                    padding: EdgeInsets.zero,
                    size: isStringOnTop ? size - 35 : size - 32,
                  );
                },
              );
            },
          ),
        ],
      );
    });

    List<Widget> children = [];
    if (isStringOnTop) {
      children.add(title);
      children.add(space);
      children.add(qrCode);
    } else {
      children.add(qrCode);
      children.add(space);
      children.add(title);
    }

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: context.tokens.spacing.vsdslSpacing4xl.top - 1),
      child: Column(
        children: children,
      ),
    );
  }
}
