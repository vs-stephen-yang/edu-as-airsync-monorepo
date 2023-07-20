import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  CustomTextFormField(
      {super.key, this.controller,
        this.labelText,
        this.errorText,
        this.inputFormatter});

  final TextEditingController? controller;
  final String? labelText;
  String? errorText;
  final List<TextInputFormatter>? inputFormatter;

  @override
  State<StatefulWidget> createState() {
    return CustomTextFormFieldState();
  }

}
class CustomTextFormFieldState extends State<CustomTextFormField> {

  TextStyle errorTextStyle = const TextStyle(color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleBlue = const TextStyle(color: Colors.blue);
    TextStyle textStyleGrey = const TextStyle(color: Colors.grey);
    TextStyle textStyleWhite = const TextStyle(color: Colors.white);
    OutlineInputBorder outlineInputBorderBlue = const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Colors.blue),
    );
    OutlineInputBorder outlineInputBorderGrey = const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Colors.grey),
    );
    return TextFormField(
      controller: widget.controller,
      // initialValue: initialValue,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: textStyleGrey,
        floatingLabelStyle:
        MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.focused)
              ? textStyleBlue
              : textStyleGrey;
        }),
        errorText: widget.errorText,
        errorStyle: errorTextStyle,
        border: outlineInputBorderBlue,
        enabledBorder: outlineInputBorderGrey,
        errorBorder: outlineInputBorderGrey,
        focusedErrorBorder: outlineInputBorderBlue,
      ),
      style: textStyleWhite,
      inputFormatters: widget.inputFormatter,
      // onChanged: (_) {},
    );
  }

  void setErrorMsg(String text) {
    setState(() {
      widget.errorText = text;
      errorTextStyle = const TextStyle(color: Colors.red);
    });
  }
}
