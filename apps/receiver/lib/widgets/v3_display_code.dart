import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/utility/misc_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3DisplayCode extends StatelessWidget {
  const V3DisplayCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InstanceInfoProvider>(
      builder: (_, instanceInfoProvider, __) {
        return Semantics(
          identifier: 'v3_qa_display_code',
          // Trialling is display code, should not use - to confuse user
          child: Text(
            getDisplayCodeVisualIdentity(instanceInfoProvider.displayCode),
            style: context.tokens.textStyle.airsyncFontDisplay.apply(
              color: context.tokens.color.vsdslColorOnSurface,
            ),
          ),
        );
      },
    );
  }
}