import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3SettingMenuSubItemFocus extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? identifier;
  final bool excludeSemantics;

  const V3SettingMenuSubItemFocus(
      {super.key,
      required this.child,
      this.label,
      this.identifier,
      this.excludeSemantics = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, settingsProvider, _) {
      return V3Focus(
        label: label,
        identifier: identifier,
        excludeSemantics: excludeSemantics,
        onFocusMove: settingsProvider.onSubFocusMove,
        child: child,
      );
    });
  }
}
