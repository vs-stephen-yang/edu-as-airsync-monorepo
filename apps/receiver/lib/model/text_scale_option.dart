import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';

enum ResizeTextSizeOption {
  normal(0),
  large(1),
  xlarge(2);

  final int value;

  const ResizeTextSizeOption(this.value);

  static List<String> resizeTextSizeItems(BuildContext context) {
    return _resizeTextSizeMap(context).values.toList();
  }

  static ResizeTextSizeOption fromValue(int value) {
    return ResizeTextSizeOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => ResizeTextSizeOption.normal, // Return a default value
    );
  }

  static Map<ResizeTextSizeOption, String> _resizeTextSizeMap(
      BuildContext context) {
    final resizeTextSizeMap = {
      ResizeTextSizeOption.normal:
          '${S.of(context).v3_settings_resize_text_size_normal} (1.0)',
      ResizeTextSizeOption.large:
          '${S.of(context).v3_settings_resize_text_size_large} (1.5)',
      ResizeTextSizeOption.xlarge:
          '${S.of(context).v3_settings_resize_text_size_extra_large} (2.0)',
    };
    return resizeTextSizeMap;
  }

  String rawValue(BuildContext context) {
    return ResizeTextSizeOption._resizeTextSizeMap(context)[this]!;
  }
}
