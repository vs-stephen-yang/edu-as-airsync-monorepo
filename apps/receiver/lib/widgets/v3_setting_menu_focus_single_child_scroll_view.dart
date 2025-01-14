import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/base_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class V3SettingMenuFocusSingleChildScrollView extends StatelessWidget {
  const V3SettingMenuFocusSingleChildScrollView({
    super.key,
    this.children = const <Widget>[],
    this.primaryFocus = false,
  });

  final List<Widget> children;
  final bool primaryFocus;

  @override
  Widget build(BuildContext context) {
    final focusManager = Provider.of<SettingsProvider>(context);
    final FocusNode? node = primaryFocus ? focusManager.subFocusNode : null;

    return BaseFocusSingleChildScrollView(
      focusNode: node,
      children: children,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyUpEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          focusManager.requestMainMenuFocus();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
    );
  }
}
