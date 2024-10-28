import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/widgets/v3_cast_devices_view.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_no_network_status.dart';
import 'package:display_flutter/widgets/v3_qrcode_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3CastDeviceInfo extends StatelessWidget {
  const V3CastDeviceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 910,
      height: 604,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          side: BorderSide(
            width: 1,
            color: context.tokens.color.vsdslColorOutline,
          ),
        ),
        color: context.tokens.color.vsdslColorSurface100.withOpacity(0.64),
      ),
      child: Consumer<ConnectivityProvider>(
        builder: (_, connectivityProvider, __) {
          return connectivityProvider.connectionStatus ==
                  ConnectivityResult.none
              ? const V3NoNetworkStatus()
              : Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 13,
                      right: 0,
                      child: AutoSizeText(
                        S.of(context).v3_cast_to_device_menu_title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: context.tokens.color.vsdslColorOnSurface,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 51,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: context.tokens.color.vsdslColorOutline,
                      ),
                    ),
                    Positioned(
                      left: 529,
                      top: 51,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: context.tokens.color.vsdslColorOutline,
                      ),
                    ),
                    Positioned(
                      left: 53,
                      top: 91,
                      bottom: 0,
                      child: SizedBox(
                        width: 529,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const V3Instruction(isCastToDevice: true),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 420,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1.5,
                                      color: context
                                          .tokens.color.vsdslColorOutline,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: AutoSizeText(
                                      S.of(context).v3_cast_to_device_menu_or,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: context.tokens.color
                                              .vsdslColorSurface500),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1.5,
                                      color: context
                                          .tokens.color.vsdslColorOutline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 17),
                            const V3QrCodeInstruction(),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 51,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 387,
                        child: V3CastDevicesView(),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class V3QrCodeInstruction extends StatelessWidget {
  const V3QrCodeInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 160,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.radii.vsdslRadiusXl,
          side: BorderSide(
            width: 1,
            color: context.tokens.color.vsdslColorOutline,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 27,
      ),
      child: Row(
        children: [
          const V3QrCodeImage(size: 120),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                S.of(context).v3_cast_to_device_menu_quick_connect1,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: context.tokens.color.vsdslColorOnSurfaceVariant,
                ),
              ),
              const SizedBox(width: 5),
              AutoSizeText(
                S.of(context).v3_cast_to_device_menu_quick_connect2,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  color: context.tokens.color.vsdslColorOnSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
