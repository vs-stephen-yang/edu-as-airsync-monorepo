import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3CustomTextFormField extends StatefulWidget {
  const V3CustomTextFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.label,
    required this.identifier,
    this.maxTextLength,
    required this.inputFormatter,
    required this.onFieldChanged,
    required this.onFieldSubmitted,
    this.onTap,
    this.enable = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final String label;
  final String identifier;
  final int? maxTextLength;
  final List<TextInputFormatter>? inputFormatter;
  final ValueChanged<String> onFieldChanged;
  final GestureTapCallback? onTap;
  final ValueChanged<String> onFieldSubmitted;
  final bool enable;

  @override
  V3CustomTextFormFieldState createState() => V3CustomTextFormFieldState();
}

class V3CustomTextFormFieldState extends State<V3CustomTextFormField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      identifier: widget.identifier,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enable,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.enable
              ? context.tokens.color.vsdswColorSurface100
              : context.tokens.color.vsdswColorDisabled,
          hintText: widget.hintText,
          hintStyle: TextStyle(
              fontSize: 12, color: context.tokens.color.vsdswColorOnDisabled),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: context.tokens.radii.vsdswRadiusFull,
            borderSide: BorderSide(
                color: context.tokens.color.vsdswColorOutline, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: context.tokens.radii.vsdswRadiusFull,
            borderSide: BorderSide(
                color: context.tokens.color.vsdswColorOutline, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: context.tokens.radii.vsdswRadiusFull,
            borderSide: BorderSide(
                color: context.tokens.color.vsdswColorDisabled, width: 2),
          ),
          focusedBorder: _focusedBorder(),
          error: _errorWidget(context),
          errorBorder: _errorBorder(),
        ),
        maxLength: widget.maxTextLength,
        inputFormatters: widget.inputFormatter,
        onChanged: (_) {
          widget.onFieldChanged(_);
        },
        onTap: () {
          if (widget.onTap != null) widget.onTap!();
        },
        onFieldSubmitted: (value) {
          widget.onFieldSubmitted(value);
        },
      ),
    );
  }

  Row? _errorWidget(BuildContext context) {
    if (_errorText != null && _errorText!.isNotEmpty) {
      return Row(children: [
        const SizedBox(
            width: 16,
            height: 16,
            child: Image(
                image: Svg('assets/images/v3_ic_display_code_error.svg'))),
        const Padding(
          padding: EdgeInsets.only(right: 8),
        ),
        Text(
          _errorText!,
          style: TextStyle(
              fontSize: 12, color: context.tokens.color.vsdswColorError),
        )
      ]);
    }

    return null;
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: context.tokens.radii.vsdswRadiusFull,
      borderSide: BorderSide(
          color: context.tokens.color.vsdswColorPrimaryVariant, width: 2),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: context.tokens.radii.vsdswRadiusFull,
      borderSide:
          BorderSide(color: context.tokens.color.vsdswColorError, width: 2),
    );
  }

  void setErrorMsg(String text) {
    setState(() {
      _errorText = text;
    });
  }
}
