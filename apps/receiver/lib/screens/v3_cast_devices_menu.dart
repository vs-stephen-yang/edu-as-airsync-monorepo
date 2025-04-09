import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_cast_device_info.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3CastDevicesMenu extends StatelessWidget {
  const V3CastDevicesMenu({super.key, required this.primaryFocusNode});

  static bool fromShortcut = false;
  final FocusNode primaryFocusNode;

  @override
  Widget build(BuildContext context) {
    fromShortcut = false;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: context.tokens.color.vsdslColorSurface100,
      insetPadding: EdgeInsets.zero,
      elevation: 16.0,
      shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
      child: FocusScope(
        autofocus: true,
        node: FocusScopeNode(),
        child: Stack(
          children: [
            const V3CastDeviceInfo(),
            Positioned(
              right: 13,
              bottom: 13,
              child: V3Focus(
                label: S.current.v3_lbl_close_feature_set_cast_device,
                identifier: 'v3_qa_close_feature_set_cast_device',
                child: SizedBox(
                  width: 33,
                  height: 33,
                  child: IconButton(
                    focusNode: primaryFocusNode,
                    icon: SvgPicture.asset(
                      'assets/images/ic_menu_close_gray.svg',
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
            ),
          ],
        ),
      ),
    );
  }
}
