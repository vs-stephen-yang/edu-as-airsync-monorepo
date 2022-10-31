import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
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
    _open = widget.bOpen;
    String name = widget.name;
    if (widget.name.contains('\n')) name = widget.name.replaceAll('\n', ' ');
    if (name.length > 10) name = name.substring(0, 10) + '..';

    String shortName = name.toUpperCase();
    var reg = RegExp(r'^[A-Z0-9.,-]+\s+[A-Z0-9.,-]+$');
    if (reg.hasMatch(shortName)) {
      shortName = shortName.split(' ').first.substring(0, 1) +
          shortName.split(' ').last.substring(0, 1);
    } else if (name.length > 1) {
      shortName = name.substring(0, 2).toUpperCase();
    }

    Widget loading = widget.bWait
        ? buildRotationLoadingIcon()
        : Text(
            shortName,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          );

    Widget cell = FocusElevatedButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
          loading,
        ],
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        primary: _open ? AppColors.primary_blue : AppColors.toggle_bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.height)),
      ),
      onClick: () {
        _open = !_open;
        setState(() {
          _controller.repeat(reverse: false);
          widget.onOpen(_open);
        });
      },
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
        },
      ),
    );

    return SizedBox(
      height: widget.height,
      width: widget.width,
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
