import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextScaleProvider extends ChangeNotifier {
  TextScaleProvider() {
    log.info('TextScaleProvider: _load');
    _load();
  }

  TextSizeOption? _textSize;

  TextSizeOption get textSize => _textSize ?? _getDefaultTextSizeOption();

  TextScaler? get platformTextScale {
    if (kIsWeb) {
      return null;
    }

    return TextScaler.linear(textSize.value);
  }

  setTextSize(TextSizeOption textSize) {
    _textSize = textSize;
    _save();
    notifyListeners();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
        'app_textSize', _textSize?.value ?? _getDefaultTextSizeOption().value);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _textSize = TextSizeOptionExtension.valueToOption(
        prefs.getDouble('app_textSize') ?? 1.0);
    log.info('TextScaleProvider: $_textSize');
    notifyListeners();
  }

  TextSizeOption _getDefaultTextSizeOption() {
    return TextSizeOption.normal;
  }
}

enum TextSizeOption {
  normal,
  large,
  xlarge,
}

extension TextSizeOptionExtension on TextSizeOption {
  String get name => _describeEnum(this);

  String get _displayTitle {
    switch (this) {
      case TextSizeOption.normal:
        return S.current.v3_setting_accessibility_size_normal;
      case TextSizeOption.large:
        return S.current.v3_setting_accessibility_size_large;
      case TextSizeOption.xlarge:
        return S.current.v3_setting_accessibility_size_xlarge;
    }
  }

  double get value {
    switch (this) {
      case TextSizeOption.normal:
        return 1.0;
      case TextSizeOption.large:
        return 1.5;
      case TextSizeOption.xlarge:
        return 2.0;
    }
  }

  static TextSizeOption valueToOption(double value) {
    switch (value) {
      case 1.0:
        return TextSizeOption.normal;
      case 1.5:
        return TextSizeOption.large;
      case 2.0:
        return TextSizeOption.xlarge;
      default:
        return TextSizeOption.normal;
    }
  }

  String _describeEnum(TextSizeOption enumEntry) {
    return '${enumEntry._displayTitle} (${enumEntry.value})';
  }
}
