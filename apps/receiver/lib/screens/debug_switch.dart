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
  bool _showDebugOverlay = false;
  bool _useSoftwareDecode = false;
  bool _applyRK3588 = false;
  bool _applyRK3288n3399 = false;
  bool _applyMTK9950 = false;
  bool _applyAMLogic982n1516 = false;
  bool _applyGeneric = false;

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

  void _applyVendorParam(String vendor, bool value) async {
    DeviceFeatureAdapter.UseRK3588QuickDecode = false;
    DeviceFeatureAdapter.UseRK3288_3399QuickDecode = false;
    DeviceFeatureAdapter.UseMTK9950QuickDecode = false;
    DeviceFeatureAdapter.UseAMLogic982_1516QuickDecode = false;
    DeviceFeatureAdapter.UseGenericQuickDecode = false;

    if (vendor == 'RK3588') {
      DeviceFeatureAdapter.UseRK3588QuickDecode = value;
    } else if (vendor == 'RK3288_3399') {
      DeviceFeatureAdapter.UseRK3288_3399QuickDecode = value;
    } else if (vendor == 'MTK9950') {
      DeviceFeatureAdapter.UseMTK9950QuickDecode = value;
    } else if (vendor == 'AMLogic982_1516') {
      DeviceFeatureAdapter.UseAMLogic982_1516QuickDecode = value;
    } else if (vendor == 'Generic') {
      DeviceFeatureAdapter.UseGenericQuickDecode = value;
    }

    await DeviceFeatureAdapter.save();

    setState(() {
      _applyRK3588 = DeviceFeatureAdapter.UseRK3588QuickDecode;
      _applyRK3288n3399 = DeviceFeatureAdapter.UseRK3288_3399QuickDecode;
      _applyMTK9950 = DeviceFeatureAdapter.UseMTK9950QuickDecode;
      _applyAMLogic982n1516 = DeviceFeatureAdapter.UseAMLogic982_1516QuickDecode;
      _applyGeneric = DeviceFeatureAdapter.UseGenericQuickDecode;
      _notifyRestart();
    });
  }

  void _initialize() {
    _showDebugOverlay = DeviceFeatureAdapter.ShowDebugOverlay;
    _useSoftwareDecode = DeviceFeatureAdapter.UseSoftwareDecode;
    _applyRK3588 = DeviceFeatureAdapter.UseRK3588QuickDecode;
    _applyRK3288n3399 = DeviceFeatureAdapter.UseRK3288_3399QuickDecode;
    _applyMTK9950 = DeviceFeatureAdapter.UseMTK9950QuickDecode;
    _applyAMLogic982n1516 = DeviceFeatureAdapter.UseAMLogic982_1516QuickDecode;
    _applyGeneric = DeviceFeatureAdapter.UseGenericQuickDecode;
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
                            title: const Text('Quick Decode: 3588 (RK)'),
                            value: _applyRK3588,
                            onChanged: (value) => _applyVendorParam('RK3588', value)
                        ),
                        SwitchListTile(
                            title: const Text('Quick Decode: 3288, 3399 (RK)'),
                            value: _applyRK3288n3399,
                            onChanged: (value) => _applyVendorParam('RK3288_3399', value)
                        ),
                        SwitchListTile(
                            title: const Text('Quick Decode: 9950 (MTK)'),
                            value: _applyMTK9950,
                            onChanged: (value) => _applyVendorParam('MTK9950', value)
                        ),
                        SwitchListTile(
                            title: const Text('Quick Decode: 982, 1516 (AMLogic)'),
                            value: _applyAMLogic982n1516,
                            onChanged: (value) => _applyVendorParam('AMLogic982_1516', value)
                        ),
                        SwitchListTile(
                            title: const Text('Quick Decode: Generic'),
                            value: _applyGeneric,
                            onChanged: (value) => _applyVendorParam('Generic', value)
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
