import 'package:display_flutter/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

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

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width;
    double height = widget.height;
    _open = widget.bOpen;
    String name = widget.name;
    if (widget.name.contains("\n")) name = widget.name.replaceAll("\n", " ");
    if (name.length > 10) name = name.substring(0, 10) + "..";

    String shortName = name.toUpperCase();
    var reg = RegExp(r'^[A-Z0-9.,-]+\s+[A-Z0-9.,-]+$');
    if (reg.hasMatch(shortName)) {
      shortName = shortName.split(" ").first.substring(0, 1) +
          shortName.split(" ").last.substring(0, 1);
    } else if (name.length > 1) {
      shortName = name.substring(0, 2).toUpperCase();
    }

    Widget loading = widget.bWait
        ? buildRotationLoadingIcon()
        : Text(shortName,
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 16));

    Widget cell = InkWell(
      onTap: () {
        _open = !_open;
        setState(() {
          _controller.repeat(reverse: false);
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
                child: loading,
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

  Widget buildRotationLoadingIcon() {
    return RotationTransition(
      turns: _animation,
      child: const Image(
        image: Svg(
          'assets/images/ic_loading.svg',
          size: Size.square(32),
        ),
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
