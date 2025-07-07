import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class V3PresentDeviceListButton extends StatelessWidget {
  const V3PresentDeviceListButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return V3Focus(
      label: S.current.v3_lbl_device_list_button_device_list,
      identifier: 'v3_qa_device_list_button_device_list',
      button: true,
      child: ExcludeSemantics(
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: context.tokens.color.vsdswColorDisabled,
            backgroundColor: context.tokens.color.vsdswColorPrimary,
            fixedSize: const Size(300, 48),
            shape: RoundedRectangleBorder(
              borderRadius: context.tokens.radii.vsdswRadiusFull,
            ),
            shadowColor: Colors.grey,
            elevation: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/ic_device_list_screen.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  context.tokens.color.vsdswColorOnTertiary,
                  BlendMode.srcIn,
                ),
              ),
              const Gap(8),
              V3AutoHyphenatingText(
                S.of(context).main_device_list,
                style: TextStyle(
                  color: context.tokens.color.vsdswColorOnTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 0.28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
