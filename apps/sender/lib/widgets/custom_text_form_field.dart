import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField(
      {super.key,
      this.controller,
      this.labelText,
      this.errorText,
      this.labelBackgroundColor = Colors.white,
      this.labelTextColor = Colors.grey,
      this.inputFormatter,
      this.maxLength,
      this.onChanged,
      this.onTap,
      required this.focusNode,
      required this.onFieldSubmitted});

  final TextEditingController? controller;
  final String? labelText;
  final String? errorText;
  final Color? labelBackgroundColor;
  final Color? labelTextColor;
  final List<TextInputFormatter>? inputFormatter;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final FocusNode focusNode;
  final ValueChanged<String> onFieldSubmitted;
  final int? maxLength;

  @override
  State<StatefulWidget> createState() {
    return CustomTextFormFieldState();
  }
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  String? _errorText;
  TextStyle errorTextStyle =
      const TextStyle(color: Color.fromRGBO(153, 153, 153, 1));

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: widget.labelTextColor);
    OutlineInputBorder outlineInputBorderBlue = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      borderSide: BorderSide(width: 1, color: Colors.blue),
    );
    OutlineInputBorder outlineInputBorderGrey = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      borderSide: BorderSide(width: 1, color: Colors.white),
    );
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.labelBackgroundColor,
        labelText: widget.labelText,
        labelStyle: textStyle,
        floatingLabelStyle: textStyle,
        errorText: _errorText ?? widget.errorText,
        errorStyle: errorTextStyle,
        border: outlineInputBorderBlue,
        enabledBorder: outlineInputBorderGrey,
        errorBorder: outlineInputBorderGrey,
        focusedErrorBorder: outlineInputBorderBlue,
      ),
      maxLength: widget.maxLength,
      style: textStyle,
      inputFormatters: widget.inputFormatter,
      onChanged: (_) {
        if (widget.onChanged != null) widget.onChanged!(_);
      },
      onTap: () {
        if (widget.onTap != null) widget.onTap!();
      },
      onFieldSubmitted: (value) {
        widget.onFieldSubmitted(value);
      },
    );
  }

  void setDescriptionMsg(String text) {
    if (!mounted) return;
    setState(() {
      _errorText = text;
      errorTextStyle = const TextStyle(color: Color.fromRGBO(153, 153, 153, 1));
    });
  }

  void setErrorMsg(String text) {
    if (!mounted) return;
    setState(() {
      _errorText = text;
      errorTextStyle = const TextStyle(color: Colors.red);
    });
  }
}
