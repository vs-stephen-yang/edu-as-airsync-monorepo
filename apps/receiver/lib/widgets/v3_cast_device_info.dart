import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/widgets/v3_cast_devices_view.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_no_network_status.dart';
import 'package:display_flutter/widgets/v3_qrcode_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3CastDeviceInfo extends StatelessWidget {
  const V3CastDeviceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
      return Container(
        alignment: Alignment.center,
        width: isLandscape ? 910 : 604,
        height: isLandscape ? 628 : 1027,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            side: BorderSide(
              width: 1,
              color: context.tokens.color.vsdslColorOutline,
            ),
          ),
          color: context.tokens.color.vsdslColorSurface100,
        ),
        child: Consumer<ConnectivityProvider>(
          builder: (_, connectivityProvider, __) {
            return connectivityProvider.connectionStatus ==
                    ConnectivityResult.none
                ? const V3NoNetworkStatus()
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Gap(13),
                      Container(
                        height: 45,
                        alignment: Alignment.center,
                        child: Text(
                          S.of(context).v3_cast_to_device_menu_title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: context.tokens.color.vsdslColorOnSurface,
                          ),
                        ),
                      ),
                      const Gap(13),
                      Container(
                        height: 1,
                        color: context.tokens.color.vsdslColorOutline,
                      ),
                      if (isLandscape)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 10,
                                child: Container(
                                  height: 525,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Scrollbar(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const V3Instruction(
                                              isCastToDevice: true),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 420,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 1.5,
                                                    color: context.tokens.color
                                                        .vsdslColorOutline,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  child: Text(
                                                    S
                                                        .of(context)
                                                        .v3_cast_to_device_menu_or,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: context
                                                            .tokens
                                                            .color
                                                            .vsdslColorOnSurfaceVariant),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    height: 1.5,
                                                    color: context.tokens.color
                                                        .vsdslColorOutline,
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
                                )),
                            Expanded(
                              flex: 7,
                              child: Container(
                                height: 550,
                                decoration: ShapeDecoration(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(30)),
                                  ),
                                  color: context
                                      .tokens.color.vsdslColorSurface200
                                      .withOpacity(0.32),
                                ),
                                child: const V3CastDevicesView(),
                              ),
                            ),
                          ],
                        ),
                      if (!isLandscape) ...[
                        Expanded(
                          flex: 16,
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 35),
                                child: Column(
                                  children: [
                                    const V3Instruction(isCastToDevice: true),
                                    Row(
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
                                          child: Text(
                                            S
                                                .of(context)
                                                .v3_cast_to_device_menu_or,
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
                                    const Gap(17),
                                    const V3QrCodeInstruction(
                                        widthExpand: true),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 13,
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30)),
                              ),
                              color: context.tokens.color.vsdslColorSurface200
                                  .withOpacity(0.32),
                            ),
                            child: const V3CastDevicesView(),
                          ),
                        ),
                      ],
                    ],
                  );
          },
        ),
      );
    });
  }
}

class V3QrCodeInstruction extends StatelessWidget {
  const V3QrCodeInstruction({super.key, this.widthExpand = false});

  final bool widthExpand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthExpand ? null : 420,
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
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).v3_cast_to_device_menu_quick_connect1,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      S.of(context).v3_cast_to_device_menu_quick_connect2,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
