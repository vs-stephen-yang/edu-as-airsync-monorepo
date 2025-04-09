import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class V3SettingMenuListItemFocus extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double borderWidth;
  final FocusNode? focusNode;
  final String? label;
  final String? identifier;

  const V3SettingMenuListItemFocus({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.borderWidth = 2.0,
    this.onTap,
    this.focusNode,
    this.label,
    this.identifier,
  });

  @override
  State<V3SettingMenuListItemFocus> createState() =>
      _V3SettingMenuListItemFocusState();
}

class _V3SettingMenuListItemFocusState
    extends State<V3SettingMenuListItemFocus> {
  bool _isFocused = false;

  void _onFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, settingsProvider, _) {
      return Focus(
        focusNode: widget.focusNode,
        onFocusChange: _onFocusChange,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.select) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return settingsProvider.onSubFocusMove(node, event);
        },
        child: Semantics(
          label: widget.label,
          identifier: widget.identifier,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_isFocused)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.tokens.color.vsdslColorSecondary,
                        width: widget.borderWidth,
                      ),
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.borderWidth),
                  child: InkWell(
                    borderRadius: widget.borderRadius,
                    onTap: widget.onTap,
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
