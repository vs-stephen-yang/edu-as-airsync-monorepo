import 'package:display_flutter/app_colors.dart';
import 'package:flutter/material.dart';

class CheckBoxSwitch extends StatefulWidget {
  bool bOpen, bEdit, bRemove, bSplit, bWait;
  ValueChanged<bool> onOpen;
  ValueChanged onRemove;
  double width, height;
  String name;
  int splitIndex;

  late Key? key;

  CheckBoxSwitch({
    Key? itemKey,
    this.bOpen = false,
    this.bEdit = false,
    this.bRemove = false,
    this.bSplit = false,
    required this.bWait,
    required this.splitIndex,
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

  /// Whether the button is On
  bool _open = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width;
    double height = widget.height;
    _open = widget.bOpen;
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
            borderRadius: BorderRadius.circular(height),
            color: _open ? AppColors.primary_blue : AppColors.toggle_bg,
          ),
          child: Row(
            children: [
              // Visibility(
              //     visible: widget.bSplit && widget.splitIndex > 0 && _open,
              //     child: Container(
              //       alignment: Alignment.center,
              //       width: widget.width * 0.15,
              //       height: height,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.only(
              //           topLeft: Radius.circular(height),
              //           bottomLeft: Radius.circular(height),
              //         ),
              //         color: AppColors.primary_white,
              //       ),
              //       child: Text(widget.splitIndex.toString(),
              //           style: const TextStyle(
              //               color: AppColors.primary_blue, fontSize: 16)),
              //     )),
              Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(widget.width * 0.1, 0, 0, 0),
                child: Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              )),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.fromLTRB(0, 0, widget.width*0.1, 0),
                child: Text(shortName,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          )),
    );

    Widget checkBox = Visibility(
        visible: widget.bEdit,
        child: Checkbox(
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith(
                (states) => AppColors.primary_red),
            value: widget.bRemove,
            onChanged: (bool? value) {
              setState(() {
                widget.bRemove = value!;
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
    return widget.bRemove;
  }
}
