import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/log_upload.dart';
import 'package:display_flutter/utility/webrtc_util.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

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
  bool _showOldUI = false;
  bool _showDebugOverlay = false;
  bool _useSoftwareDecode = false;
  bool _useQuickDecodeParams = false;
  bool _dumpSrtpPackets = false;
  bool _enableWebRtcTracing = false;
  bool _startWebRtcTracing = false;
  bool _verboseWebRtcLog = false;
  bool _enableWebRtcH264BaselineProfile = false;
  bool _iceGatheringContinually = false;

  void _notifyRestart() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Restart the program to apply the changes.")));
  }

  void _showOldUIChanged(bool value) async {
    DeviceFeatureAdapter.showOldUI = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _showOldUI = value;
      _notifyRestart();
    });
  }

  void _showDebugOverlayChanged(bool value) async {
    DeviceFeatureAdapter.showDebugOverlay = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _showDebugOverlay = value;
      _notifyRestart();
    });
  }

  void _enableSoftwareDecode(bool value) async {
    DeviceFeatureAdapter.useSoftwareDecode = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _useSoftwareDecode = value;
      _notifyRestart();
    });
  }

  void _enableQuickDecode(bool value) async {
    DeviceFeatureAdapter.useQuickDecodeParams = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _useQuickDecodeParams = value;
      _notifyRestart();
    });
  }

  void _changeGatheringPolicy(bool value) async {
    DeviceFeatureAdapter.iceGatheringContinually = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _iceGatheringContinually = value;
      _notifyRestart();
    });
  }

  void _enableDumpSrtpPackets(bool value) async {
    DeviceFeatureAdapter.dumpSrtpPackets = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _dumpSrtpPackets = value;
      _notifyRestart();
    });
  }

  void _changeH264BaselineProfile(bool value) async {
    DeviceFeatureAdapter.enableWebRtcH264BaselineProfile = value;
    await DeviceFeatureAdapter.save();

    setState(() {
      _enableWebRtcH264BaselineProfile = value;
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
      WebRTCUtil.startWebRtcTracingCapture();
    } else {
      WebRTCUtil.stopWebRtcTracingCapture();
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
    _showOldUI = DeviceFeatureAdapter.showOldUI;
    _showDebugOverlay = DeviceFeatureAdapter.showDebugOverlay;
    _useSoftwareDecode = DeviceFeatureAdapter.useSoftwareDecode;
    _enableWebRtcH264BaselineProfile =
        DeviceFeatureAdapter.enableWebRtcH264BaselineProfile;
    _useQuickDecodeParams = DeviceFeatureAdapter.useQuickDecodeParams;
    _enableWebRtcTracing = DeviceFeatureAdapter.enableWebRtcTracing;
    _verboseWebRtcLog = DeviceFeatureAdapter.verboseWebRtcLog;
    _dumpSrtpPackets = DeviceFeatureAdapter.dumpSrtpPackets;
    _iceGatheringContinually = DeviceFeatureAdapter.iceGatheringContinually;
  }

  @override
  Widget build(BuildContext context) {
    _initialize();

    return MenuDialog(
      backgroundColor: AppColors.primaryGrey,
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
                            title: const Text('Show Old UI'),
                            value: _showOldUI,
                            onChanged: _showOldUIChanged),
                        SwitchListTile(
                          title: const Text('Show Debug Overlay'),
                          value: _showDebugOverlay,
                          onChanged: _showDebugOverlayChanged,
                        ),
                        SwitchListTile(
                          title: const Text('Software Decode'),
                          value: _useSoftwareDecode,
                          onChanged: _enableSoftwareDecode,
                        ),
                        SwitchListTile(
                          title:
                              const Text('Enable WebRTC H264 Baseline Profile'),
                          value: _enableWebRtcH264BaselineProfile,
                          onChanged: _changeH264BaselineProfile,
                        ),
                        SwitchListTile(
                          title: const Text('Quick Decode'),
                          value: _useQuickDecodeParams,
                          onChanged: (value) => _enableQuickDecode(value),
                        ),
                        SwitchListTile(
                          title: const Text('ICE Gathering Continually'),
                          value: _iceGatheringContinually,
                          onChanged: (value) => _changeGatheringPolicy(value),
                        ),
                        if (AppConfig.of(context)!
                            .settings
                            .isDevelopEnvironment)
                          SwitchListTile(
                            title: const Text('Dump SRTP Packets'),
                            value: _dumpSrtpPackets,
                            onChanged: (value) => _enableDumpSrtpPackets(value),
                          ),
                        SwitchListTile(
                          title: const Text('Enable WebRTC Tracing'),
                          value: _enableWebRtcTracing,
                          onChanged: (value) =>
                              _changeEnableWebRtcTracing(value),
                        ),
                        SwitchListTile(
                          title: const Text('WebRTC Tracing Capture'),
                          value: _startWebRtcTracing,
                          onChanged: (value) =>
                              _changeStartWebRtcTracing(value),
                        ),
                        SwitchListTile(
                          title: const Text('WebRTC Verbose log'),
                          value: _verboseWebRtcLog,
                          onChanged: (value) => _changeWebRtcLogVerbose(value),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Upload log
                              uploadLog('log');

                              MotionToast.success(
                                description:
                                    const Text("Logs uploaded successfully"),
                              ).show(context);
                            },
                            child: const Text(
                              'Upload log',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
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
