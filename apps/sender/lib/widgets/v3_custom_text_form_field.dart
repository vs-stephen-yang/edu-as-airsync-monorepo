import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class V3CustomTextFormField extends StatefulWidget {
  const V3CustomTextFormField(
      {super.key,
      required this.controller,
      required this.focusNode,
      this.hintText,
      required this.maxTextLength,
      this.inputFormatter,
      required this.onFieldChanged,
      this.onTap,
      required this.onFieldSubmitted});

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final int maxTextLength;
  final List<TextInputFormatter>? inputFormatter;
  final ValueChanged<String> onFieldChanged;
  final GestureTapCallback? onTap;
  final ValueChanged<String> onFieldSubmitted;

  @override
  V3CustomTextFormFieldState createState() => V3CustomTextFormFieldState();
}

class V3CustomTextFormFieldState extends State<V3CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.tokens.color.vsdslColorSurface100,
        hintText: widget.hintText,
        hintStyle: TextStyle(
            fontSize: 12, color: context.tokens.color.vsdslColorOnDisabled),
        enabledBorder: OutlineInputBorder(
          borderRadius: context.tokens.radii.vsdslRadiusFull,
          borderSide: BorderSide(
              color: context.tokens.color.vsdslColorOutline, width: 2),
        ),
        focusedBorder: _focusedBorder(),
        errorBorder: _errorBorder(),
      ),
      onChanged: (_) {
        widget.onFieldChanged(_);
      },
      onTap: () {
        if (widget.onTap != null) widget.onTap!();
      },
      onFieldSubmitted: (value) {
        widget.onFieldSubmitted(value);
      },
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: context.tokens.radii.vsdslRadiusFull,
      borderSide: BorderSide(
          color: context.tokens.color.vsdslColorSecondaryVariant, width: 2),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: context.tokens.radii.vsdslRadiusFull,
      borderSide:
          BorderSide(color: context.tokens.color.vsdslColorError, width: 2),
    );
  }
}
