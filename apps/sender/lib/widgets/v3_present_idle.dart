import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3PresentIdle extends StatelessWidget {
  const V3PresentIdle({super.key});

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        if (Platform.isAndroid || Platform.isIOS) _qrCode(context),
        Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logo(),
                const Padding(padding: EdgeInsets.only(top: 35)),
                const V3PresentIdleMain(),
              ],
            )),
      ],
    );
  }

  Widget _logo() {
    return SvgPicture.asset('assets/images/v3_ic_airsync.svg');
  }

  Widget _qrCode(BuildContext context) {
    return Positioned(
        top: 24,
        left: 8,
        child: Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: context.tokens.color.vsdswColorSurface200,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: context.tokens.color.vsdswColorSurface200,
              ),
              borderRadius: context.tokens.radii.vsdswRadiusFull,
            ),
            shadows: context.tokens.shadow.vsdswShadowNeutralLg,
          ),
          child: IconButton(
            icon: SvgPicture.asset('assets/images/v3_ic_qrcode.svg'),
            onPressed: () {},
          ),
        ));
  }
}
