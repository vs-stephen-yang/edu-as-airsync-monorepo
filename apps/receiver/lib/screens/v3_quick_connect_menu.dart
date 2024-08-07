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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          width: 1,
          color: Color(0xFFE9EAF0),
        ),
      ),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 512,
        height: 507,
        child: DefaultTabController(
          length: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 27,
                child: Container(
                  width: 485,
                  height: 34,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color(0xFFE9EAF0),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: const Color(0xFF3C5AAA),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
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
                top: 61,
                height: 400,
                width: 500,
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
