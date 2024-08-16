import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3QuickConnectMenu extends StatelessWidget {
  const V3QuickConnectMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.tokens.color.vsdslColorSurface100,
      shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
      elevation: 5,
      child: SizedBox(
        width: 512,
        height: 507,
        child: DefaultTabController(
          length: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 13,
                top: 27,
                right: 13,
                child: Container(
                  width: 485,
                  height: 37,
                  decoration: BoxDecoration(
                    borderRadius: context.tokens.radii.vsdslRadiusLg,
                    color: context.tokens.color.vsdslColorSurface200,
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: context.tokens.color.vsdslColorSecondary,
                      borderRadius: context.tokens.radii.vsdslRadiusLg,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: context.tokens.color.vsdslColorOnSurfaceInverse,
                    unselectedLabelColor:
                        context.tokens.color.vsdslColorSecondary,
                    dividerHeight: 0,
                    tabs: [
                      Tab(
                        text: S.of(context).v3_quick_connect_menu_display_code,
                      ),
                      Tab(
                        text: S.of(context).v3_quick_connect_menu_qrcode,
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 118,
                height: 320,
                width: 450,
                child: TabBarView(
                  children: [
                    V3Instruction(isQuickConnect: true),
                    V3QrcodeQuickConnect(isStringOnTop: true, width: 190),
                  ],
                ),
              ),
              Positioned(
                right: 13,
                bottom: 13,
                child: SizedBox(
                  width: 33,
                  height: 33,
                  child: IconButton(
                    icon: const Image(
                      image: Svg('assets/images/ic_menu_minimal.svg'),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (navService.canPop()) {
                        navService.goBack();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
