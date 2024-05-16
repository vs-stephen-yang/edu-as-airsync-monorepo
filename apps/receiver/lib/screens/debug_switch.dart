import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/utility/webrtc_util.dart';
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
  bool _enableWebRtcTracing = false;
  bool _startWebRtcTracing = false;
  bool _verboseWebRtcLog = false;

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

  void _changeEnableWebRtcTracing(bool value) async {
    DeviceFeatureAdapter.enableWebRtcTracing = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _enableWebRtcTracing = value;
      _notifyRestart();
    });
  }

  void _changeStartWebRtcTracing(bool value) async {
    if (value) {
      startWebRtcTracingCapture();
    } else {
      stopWebRtcTracingCapture();
    }

    setState(() {
      _startWebRtcTracing = value;
    });
  }

  void _changeWebRtcLogVerbose(bool value) async {
    DeviceFeatureAdapter.verboseWebRtcLog = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _verboseWebRtcLog = value;
      _notifyRestart();
    });
  }

  void _initialize() {
    _showDebugOverlay = DeviceFeatureAdapter.ShowDebugOverlay;
    _useSoftwareDecode = DeviceFeatureAdapter.UseSoftwareDecode;
    _useQuickDecodeParams = DeviceFeatureAdapter.UseQuickDecodeParams;
    _enableWebRtcTracing = DeviceFeatureAdapter.enableWebRtcTracing;
    _verboseWebRtcLog = DeviceFeatureAdapter.verboseWebRtcLog;
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
                        SwitchListTile(
                            title: const Text('Enable WebRTC Tracing'),
                            value: _enableWebRtcTracing,
                            onChanged: (value) => _changeEnableWebRtcTracing(value)
                        ),
                        SwitchListTile(
                            title: const Text('WebRTC Tracing Capture'),
                            value: _startWebRtcTracing,
                            onChanged: (value) => _changeStartWebRtcTracing(value)
                        ),
                        SwitchListTile(
                            title: const Text('WebRTC Verbose log'),
                            value: _verboseWebRtcLog,
                            onChanged: (value) => _changeWebRtcLogVerbose(value)
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
