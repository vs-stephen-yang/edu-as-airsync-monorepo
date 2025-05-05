import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/providers/text_scale_provider.dart';
import 'package:display_flutter/widgets/v3_setting_2ndLayer.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3Accessibility extends StatelessWidget {
  const V3Accessibility({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
      return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
        return V3Setting2ndLayer(
            isDisable: settingsProvider.isDeviceSettingLock,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildResizeTextSize(context, settingsProvider),
            ]));
      });
    });
  }

  Widget _buildResizeTextSize(
      BuildContext context, SettingsProvider settingsProvider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            S.of(context).v3_settings_resize_text_size,
            style: TextStyle(
              color: context.tokens.color.vsdslColorOnSurfaceInverse,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(
          width: 105,
          child: CustomDropdown(
            isDisable: settingsProvider.isDeviceSettingLock,
            options: ResizeTextSizeOption.values
                .map((e) =>
                    ResizeTextSizeOption.resizeTextSizeItems(context)[e.value])
                .toList(),
            selectedValue: Provider.of<TextScaleProvider>(context, listen: true)
                .textSizeOption
                .rawValue(context),
            onChange: (String? value) {
              final textSizeOption = ResizeTextSizeOption.values.firstWhere(
                (e) =>
                    ResizeTextSizeOption.resizeTextSizeItems(
                        context)[e.value] ==
                    value,
                orElse: () => ResizeTextSizeOption.normal,
              );

              Provider.of<TextScaleProvider>(context, listen: false)
                  .updateScale(textSizeOption);
            },
          ),
        ),
      ],
    );
  }
}
