import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DismissIntent extends Intent {}

class SubmitIntent extends Intent {}

class IgnoreArrowDownIntent extends Intent {}

class IgnoreArrowUpIntent extends Intent {}

class V3TextFieldShortcutsHandler extends StatelessWidget {
  final Widget child;
  final FocusNode focusNode;

  const V3TextFieldShortcutsHandler({
    super.key,
    required this.child,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // 1. Listen to ESC (keyboard) & Back key (remote control)
        LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent(),
        LogicalKeySet(LogicalKeyboardKey.goBack): DismissIntent(),
        LogicalKeySet(LogicalKeyboardKey.exit): DismissIntent(),
        // for some reason, the exit key needs to be added twice
        LogicalKeySet(LogicalKeyboardKey.exit): DismissIntent(),

        // 2. Listen to ENTER (keyboard) & OK (remote control)
        LogicalKeySet(LogicalKeyboardKey.enter): SubmitIntent(),
        LogicalKeySet(LogicalKeyboardKey.select): SubmitIntent(),

        // 3. Listen to Arrow Up & Arrow Down
        LogicalKeySet(LogicalKeyboardKey.arrowUp): IgnoreArrowUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): IgnoreArrowDownIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) {
              focusNode.previousFocus();
              return null;
            },
          ),
          SubmitIntent: CallbackAction<SubmitIntent>(
            onInvoke: (intent) {
              focusNode.nextFocus();
              return null;
            },
          ),
          IgnoreArrowDownIntent: CallbackAction<IgnoreArrowDownIntent>(
            onInvoke: (intent) {
              focusNode.nextFocus();
              return null;
            },
          ),
          IgnoreArrowUpIntent: CallbackAction<IgnoreArrowUpIntent>(
            onInvoke: (intent) {
              focusNode.previousFocus();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
