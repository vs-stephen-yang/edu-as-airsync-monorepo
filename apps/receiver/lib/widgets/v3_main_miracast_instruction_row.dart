import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3MainMiracastInstructionRow extends StatelessWidget {
  const V3MainMiracastInstructionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MirrorStateProvider>(
      builder: (_, provider, __) {
        return provider.isSpecifiedModuleAndDFSChannel
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionIcon(
                    context,
                    'assets/images/ic_toast_alert.svg',
                    color: context.tokens.color.vsdslColorWarning,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: SizedBox(
                        width: 700,
                        child: AutoSizeText(
                          S.of(context).v3_miracast_not_support,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: context.tokens.color.vsdslColorWarning,
                          ),
                          minFontSize: 9,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildInstructionIcon(BuildContext context, String assetPath,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 35),
      child: SvgPicture.asset(
        assetPath,
        excludeFromSemantics: true,
        width: 21,
        height: 21,
        colorFilter: ColorFilter.mode(
          color ?? context.tokens.color.vsdslColorOnSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
