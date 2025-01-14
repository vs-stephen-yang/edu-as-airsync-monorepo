import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3SettingMenuSubItemFocus extends StatelessWidget {
  final Widget child;

  const V3SettingMenuSubItemFocus({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, settingsProvider, _) {
      return V3Focus(
        onFocusMove: settingsProvider.onSubFocusMove,
        child: child,
      );
    });
  }
}
