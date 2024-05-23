import 'package:display_cast_flutter/utilities/share_log.dart';
import 'package:display_cast_flutter/widgets/menu_dialog.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:flutter/material.dart';

class DebugSwitch extends StatefulWidget {
  const DebugSwitch({super.key});

  @override
  State createState() => _DebugSwitchState();
}

class _DebugSwitchState extends State<DebugSwitch> {
  void _initialize() {}

  @override
  Widget build(BuildContext context) {
    _initialize();

    final shareLogsButton = TextButton(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(Colors.white), // 设置按钮背景颜色
        foregroundColor:
            MaterialStateProperty.all<Color>(Colors.grey), // 设置按钮文字颜色
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 设置按钮圆角
            side: const BorderSide(color: Colors.grey), // 设置按钮边框
          ),
        ),
      ),
      onPressed: () {
        shareLogs();
      },
      child: const Text('Get Logs'),
    );

    return MenuDialog(
      backgroundColor: AppColors.primaryGrey,
      topTitleText: 'Debug Switch',
      content: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    shareLogsButton,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
