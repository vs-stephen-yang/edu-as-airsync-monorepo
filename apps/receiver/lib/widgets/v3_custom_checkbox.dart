import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';

class V3CustomCheckbox extends StatelessWidget {
  const V3CustomCheckbox({
    super.key,
    this.isDisable = false,
    required this.value,
    this.tristate = false,
    required this.onChanged,
  });

  final bool isDisable;
  final bool? value;
  final bool tristate;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    var colorPrimary = context.tokens.color.vsdslColorPrimary
        .withOpacity(isDisable ? 0.32 : 1);
    var colorOnPrimary = context.tokens.color.vsdslColorOnPrimary
        .withOpacity(isDisable ? 0.32 : 1);
    var colorFill = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return context.tokens.color.vsdslColorPrimary.withOpacity(0.32);
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.selected)) {
        return context.tokens.color.vsdslColorPrimary;
      }
      return Colors.transparent;
    });
    return Checkbox(
      value: value,
      tristate: tristate,
      onChanged: isDisable ? null : onChanged,
      side: BorderSide(color: colorOnPrimary, width: 2),
      activeColor: colorPrimary,
      checkColor: colorOnPrimary,
      fillColor: colorFill,
    );
  }
}
