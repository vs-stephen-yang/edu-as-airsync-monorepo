import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/text_scale_option.dart';
import 'package:flutter/widgets.dart';

abstract class TextSizeAwareStateless extends StatelessWidget {
  const TextSizeAwareStateless({super.key});

  ResizeTextSizeOption get textSize => AppPreferences().textSizeOption;

  bool get showIcon =>
      AppPreferences().textSizeOption != ResizeTextSizeOption.normal;

  /// 子類實作這個方法，而不是直接 override build()
  Widget buildWithTextSize(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppPreferences().textSizeOptionNotifier,
      builder: (context, _, __) {
        return buildWithTextSize(context);
      },
    );
  }
}
