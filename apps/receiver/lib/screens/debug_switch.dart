import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/widgets/focus_text_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';

class DebugSwitch extends StatefulWidget {
  static ValueNotifier<String> debugPanelLog = ValueNotifier('');
  static StringBuffer log = StringBuffer();

  const DebugSwitch({super.key});

  @override
  State createState() => _DebugSwitchState();

  void write(String event) {
    debugPanelLog.value = event;
  }
}

class _DebugSwitchState extends State<DebugSwitch> {
  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: AppColors.primary_grey,
      topTitleText: 'Debug Switch',
      content: Column(
        children: [
          FocusTextButton(
            child: const Text('-- clear --',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary_blue,
                )),
            onClick: () {
              DebugSwitch.log.clear();
              DebugSwitch.debugPanelLog.value = '';
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ValueListenableBuilder(
                valueListenable: DebugSwitch.debugPanelLog,
                builder: (BuildContext context, String value, Widget? child) {
                  DebugSwitch.log.write('$value \n');
                  return Text(
                    DebugSwitch.log.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary_blue,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
