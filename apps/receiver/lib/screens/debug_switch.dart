import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/widgets/focus_text_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
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
  bool _useSoftwareDecode = false;

  void _enableSoftwareDecode(bool value) async {
    DeviceFeatureAdapter.UseSoftwareDecode = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _useSoftwareDecode = value;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Changes will take effect after restarting the program.")
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _useSoftwareDecode = DeviceFeatureAdapter.UseSoftwareDecode;
    return MenuDialog(
      backgroundColor: AppColors.primary_grey,
      topTitleText: 'Debug Switch',
      content: Column(
        children: [
          SwitchListTile(
              title: const Text('Software Decode'),
              value: _useSoftwareDecode,
              onChanged: _enableSoftwareDecode
          ),
          FocusTextButton(
            child: const Text(
              '-- clear --',
              style: TextStyle(color: Colors.blue),
            ),
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
                  return Text(DebugSwitch.log.toString());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
