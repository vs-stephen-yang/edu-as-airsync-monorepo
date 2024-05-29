import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/log.dart';
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
  bool _isLogVerbose = false;
  String _selectedProfileName = '';
  int _maxBitrateKbps = 0;
  int _minBitrateKbps = 0;

  void _changeLogVerbose(bool value) async {
    setLogLevelVerbose(value);

    setState(() {
      _isLogVerbose = value;
    });
  }

  void _initialize(BuildContext context) {
    _isLogVerbose = isLogLevelVerbose();

    final Profile profile = AppConfig.of(context)!.profile;
    final Preset preset = profile.presets.first;

    _selectedProfileName = profile.name;
    _maxBitrateKbps = preset.parameters.maxBitrateKbps;
    _minBitrateKbps = preset.parameters.minBitrateKbps;
  }

  @override
  Widget build(BuildContext context) {
    _initialize(context);

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
                    Text("profile: ${_selectedProfileName}", style: new TextStyle(
                          fontSize: 14, color: Colors.red)),
                    Text("minBitrateKbps: ${_minBitrateKbps}", style: new TextStyle(
                        fontSize: 14, color: Colors.red),),
                    Text("maxBitrateKbps: ${_maxBitrateKbps}", style: new TextStyle(
                        fontSize: 14, color: Colors.red)),
                    SwitchListTile(
                        title: const Text('Verbose Log'),
                        value: _isLogVerbose,
                        onChanged: _changeLogVerbose),
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
