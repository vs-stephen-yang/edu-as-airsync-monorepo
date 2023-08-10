
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  CustomTextFormField(
      {super.key, this.controller,
        this.labelText,
        this.errorText,
        this.inputFormatter,
        this.isPassword = false, this.onChanged});

  final TextEditingController? controller;
  final String? labelText;
  String? errorText;
  final List<TextInputFormatter>? inputFormatter;
  bool isPassword = false;
  ValueChanged<String>? onChanged;

  @override
  State<StatefulWidget> createState() {
    return CustomTextFormFieldState();
  }

}
class CustomTextFormFieldState extends State<CustomTextFormField> {

  TextStyle errorTextStyle = const TextStyle(color: Colors.white38);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleWhite = const TextStyle(color: Colors.white);
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
      // initialValue: initialValue,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: textStyleWhite,
        floatingLabelStyle: textStyleWhite,
        errorText: widget.errorText,
        errorStyle: errorTextStyle,
        border: outlineInputBorderBlue,
        enabledBorder: outlineInputBorderGrey,
        errorBorder: outlineInputBorderGrey,
        focusedErrorBorder: outlineInputBorderBlue,
        suffixIcon: widget.isPassword? const Icon(Icons.remove_red_eye, color: Colors.white38,): null,
      ),
      style: textStyleWhite,
      inputFormatters: widget.inputFormatter,
      onChanged: (_) {
        if (widget.onChanged != null) widget.onChanged!(_);
      },
    );
  }

  void setErrorMsg(String text) {
    setState(() {
      widget.errorText = text;
      errorTextStyle = const TextStyle(color: Colors.red);
    });
  }
}
