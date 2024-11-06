import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/webrtc_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3TouchBackButton extends StatefulWidget {
  const V3TouchBackButton({super.key});

  @override
  State<StatefulWidget> createState() => _V3TouchBackButtonState();
}

class _V3TouchBackButtonState extends State<V3TouchBackButton> {
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = WebRTCHelper().getTouchBack();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 299,
      height: 66,
      decoration: BoxDecoration(
        color: context.tokens.color.vsdswColorSurface900,
        borderRadius: context.tokens.radii.vsdswRadiusFull,
        border:
            Border.all(color: context.tokens.color.vsdswColorOutlineVariant),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.tokens.spacing.vsdswSpacingMd.top,
        horizontal: context.tokens.spacing.vsdswSpacingLg.left,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).v3_present_touch_back_allow,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: context.tokens.color.vsdswColorOnSurfaceInverse,
            ),
          ),
          SizedBox(
            width: 56,
            height: 32,
            child: IconButton(
              icon: isButtonEnabled
                  ? SvgPicture.asset('assets/images/v3_ic_switch_on.svg')
                  : SvgPicture.asset('assets/images/v3_ic_switch_off.svg'),
              padding: EdgeInsets.zero,
              onPressed: () {
                AppAnalytics.instance.trackEvent(
                  'click_touchback',
                  EventCategory.session,
                  target: isButtonEnabled ? 'on' : 'off',
                );

                isButtonEnabled = !isButtonEnabled;
                WebRTCHelper().setTouchBack(isButtonEnabled);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
