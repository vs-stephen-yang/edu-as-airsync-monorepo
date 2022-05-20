import 'package:display_flutter/app_colors.dart';
import 'package:flutter/material.dart';

class CheckBoxSwitch extends StatefulWidget {
  bool isOpen, isEdit, isRemove;
  ValueChanged<bool> onOpen;
  ValueChanged onRemove;
  double width;
  double height;
  String name;

  late Key? key;

  CheckBoxSwitch({
    Key? itemKey,
    this.isOpen = false,
    this.isEdit = false,
    this.isRemove = false,
    required this.onOpen,
    required this.onRemove,
    required this.width,
    required this.height,
    required this.name,
  }) : super(key: itemKey) {
    key = itemKey;
  }

  @override
  State<StatefulWidget> createState() {
    return CheckBoxSwitchState();
  }
}

class CheckBoxSwitchState extends State<CheckBoxSwitch>
    with SingleTickerProviderStateMixin {
  /// The width of the button is the same as the width of NormalLayer-Text('Name'),
  /// because of the button and NormalLayer-Text are the relative position.
  double? buttonWidth = 0;

  /// Whether the button is On
  bool _open = false;

  @override
  void initState() {
    super.initState();
    buttonWidth = widget.width * 0.2;
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width;
    double height = widget.height;
    // bool _edit = widget.isEdit;
    _open = widget.isOpen;
    String name = widget.name;
    if (widget.name.contains("\n")) name = widget.name.replaceAll("\n", " ");
    if (name.length > 10) name = name.substring(0, 10) + "..";

    String shortName = name.substring(0, 2).toUpperCase();
    if (name.contains(" ")) {
      shortName = name.split(" ").first.substring(0, 1) +
          name.split(" ").last.substring(0, 1);
    }

    Widget cell = InkWell(
      onTap: () {
        _open = !_open;
        setState(() {
          widget.onOpen(_open);
        });
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: _open ? AppColors.primary_blue : AppColors.toggle_bg,
          ),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(height / 2, 0, 0, 0),
                child: Text(name,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              )),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.fromLTRB(0, 0, height / 2, 0),
                child: Text(shortName,
                    maxLines: 1,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          )),
    );

    Widget checkBox = Visibility(
        visible: widget.isEdit,
        child: Checkbox(
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith(
                (states) => AppColors.primary_red),
            value: widget.isRemove,
            onChanged: (bool? value) {
              setState(() {
                widget.isRemove = value!;
              });
            }));

    return Container(
      height: height,
      width: width,
      child: Row(
        children: [
          checkBox,
          Expanded(child: cell),
        ],
      ),
    );
  }

  void setButtonStatue({required bool status}) {
    if (status) {
      _open = true;
    } else {
      _open = false;
    }
  }

  bool getChecked() {
    return widget.isRemove;
  }
}
