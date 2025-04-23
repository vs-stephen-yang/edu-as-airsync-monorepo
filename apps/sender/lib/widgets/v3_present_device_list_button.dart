import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class V3PresentDeviceListButton extends StatelessWidget {
  const V3PresentDeviceListButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            S.current.v3_device_list_button_text,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: context.tokens.color.vsdswColorOnSurface,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 8),
          V3Focus(
            label: S.current.v3_lbl_device_list_button_device_list,
            identifier: 'v3_qa_device_list_button_device_list',
            button: true,
            child: InkWell(
              focusColor: Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
              onTap: onTap,
              child: Container(
                height: 48, // 實際觸控範圍（符合 WCAG）
                alignment: Alignment.center,
                child: Container(
                  height: 32, // 實際看起來的按鈕高度
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: ShapeDecoration(
                    color: context.tokens.color.vsdswColorTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    shadows: [
                      BoxShadow(
                        color: context.tokens.color.vsdswColorOpacityNeutralSm,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_device_list_screen.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            context.tokens.color.vsdswColorOnTertiary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          S.current.v3_device_list_button_device_list,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
