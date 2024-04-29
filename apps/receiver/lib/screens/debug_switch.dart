import 'package:display_flutter/app_colors.dart';
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
  bool _showDebugOverlay = false;
  bool _useSoftwareDecode = false;
  bool _useQuickDecodeParams = false;

  void _notifyRestart() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Restart the program to apply the changes.")
        )
    );
  }

  void _showDebugOverlayChanged(bool value) async {
    DeviceFeatureAdapter.ShowDebugOverlay = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _showDebugOverlay = value;
      _notifyRestart();
    });
  }

  void _enableSoftwareDecode(bool value) async {
    DeviceFeatureAdapter.UseSoftwareDecode = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _useSoftwareDecode = value;
      _notifyRestart();
    });
  }

  void _enableQuickDecode(bool value) async {
    DeviceFeatureAdapter.UseQuickDecodeParams = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _useQuickDecodeParams = value;
      _notifyRestart();
    });
  }

  void _initialize() {
    _showDebugOverlay = DeviceFeatureAdapter.ShowDebugOverlay;
    _useSoftwareDecode = DeviceFeatureAdapter.UseSoftwareDecode;
    _useQuickDecodeParams = DeviceFeatureAdapter.UseQuickDecodeParams;
  }

  @override
  Widget build(BuildContext context) {
    _initialize();

    return MenuDialog(
      backgroundColor: AppColors.primary_grey,
      topTitleText: 'Debug Switch',
      content: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: ValueListenableBuilder(
                  valueListenable: DebugSwitch.debugPanelLog,
                  builder: (BuildContext context, String value, Widget? child) {
                    DebugSwitch.log.write('$value \n');
                    return Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Show Debug Overlay'),
                          value: _showDebugOverlay,
                          onChanged: _showDebugOverlayChanged
                        ),
                        SwitchListTile(
                          title: const Text('Software Decode'),
                          value: _useSoftwareDecode,
                          onChanged: _enableSoftwareDecode,
                        ),
                        SwitchListTile(
                            title: const Text('Quick Decode'),
                            value: _useQuickDecodeParams,
                            onChanged: (value) => _enableQuickDecode(value)
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
