import 'dart:async';

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/providers/appSettings.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/log_upload.dart';
import 'package:display_flutter/utility/webrtc_util.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

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
  bool _showDeviceInfoOverlay = false;
  bool _useSoftwareDecode = false;
  bool _useQuickDecodeParams = false;
  bool _dumpSrtpPackets = false;
  bool _enableWebRtcTracing = false;
  bool _startWebRtcTracing = false;
  bool _verboseWebRtcLog = false;
  bool _useMulticast = false;
  bool _enableWebRtcH264BaselineProfile = false;
  bool _iceGatheringContinually = false;
  final TextEditingController _roomNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roomNumberController.text = DeviceFeatureAdapter.roomNumber;
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    super.dispose();
  }

  void _onSaveRoomNumber() async {
    DeviceFeatureAdapter.roomNumber = _roomNumberController.text;
    await DeviceFeatureAdapter.save();
    // 显示保存成功提示
    if (mounted) {
      MotionToast.success(
        description: const Text("Room number saved successfully"),
      ).show(context);
    }
  }

  void _notifyRestart() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Restart the program to apply the changes.")));
  }

  void _showDebugOverlayChanged(bool value) async {
    DeviceFeatureAdapter.showDebugOverlay = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _showDebugOverlay = value;
      _notifyRestart();
    });
  }

  void _showDeviceInfoOverlayChanged(bool value) async {
    DeviceFeatureAdapter.showDeviceInfoOverlay = value;

    if (!mounted) return;
    setState(() {
      _showDeviceInfoOverlay = value;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Adjust screen size to apply the changes.")));
    });
  }

  void _enableSoftwareDecode(bool value) async {
    DeviceFeatureAdapter.useSoftwareDecode = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _useSoftwareDecode = value;
      _notifyRestart();
    });
  }

  void _enableQuickDecode(bool value) async {
    DeviceFeatureAdapter.useQuickDecodeParams = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _useQuickDecodeParams = value;
      _notifyRestart();
    });
  }

  void _changeGatheringPolicy(bool value) async {
    DeviceFeatureAdapter.iceGatheringContinually = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _iceGatheringContinually = value;
      _notifyRestart();
    });
  }

  void _enableDumpSrtpPackets(bool value) async {
    DeviceFeatureAdapter.dumpSrtpPackets = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _dumpSrtpPackets = value;
      _notifyRestart();
    });
  }

  void _changeH264BaselineProfile(bool value) async {
    DeviceFeatureAdapter.enableWebRtcH264BaselineProfile = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _enableWebRtcH264BaselineProfile = value;
      _notifyRestart();
    });
  }

  void _changeEnableWebRtcTracing(bool value) async {
    DeviceFeatureAdapter.enableWebRtcTracing = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _enableWebRtcTracing = value;
      _notifyRestart();
    });
  }

  void _changeStartWebRtcTracing(bool value) async {
    if (value) {
      await WebRTCUtil.startWebRtcTracingCapture();
    } else {
      await WebRTCUtil.stopWebRtcTracingCapture();
    }

    if (!mounted) return;
    setState(() {
      _startWebRtcTracing = value;
    });
  }

  void _changeWebRtcLogVerbose(bool value) async {
    DeviceFeatureAdapter.verboseWebRtcLog = value;
    await DeviceFeatureAdapter.save();

    if (!mounted) return;
    setState(() {
      _verboseWebRtcLog = value;
      _notifyRestart();
    });
  }

  void _changeMulticast(bool value) async {
    await context.read<AppSettings>().setUseMulticast(value);

    if (!mounted) return;
    setState(() {
      _useMulticast = value;
      _notifyRestart();
    });
  }

  void _initialize() {
    _showDebugOverlay = DeviceFeatureAdapter.showDebugOverlay;
    _showDeviceInfoOverlay = DeviceFeatureAdapter.showDeviceInfoOverlay;
    _useSoftwareDecode = DeviceFeatureAdapter.useSoftwareDecode;
    _enableWebRtcH264BaselineProfile =
        DeviceFeatureAdapter.enableWebRtcH264BaselineProfile;
    _useQuickDecodeParams = DeviceFeatureAdapter.useQuickDecodeParams;
    _enableWebRtcTracing = DeviceFeatureAdapter.enableWebRtcTracing;
    _verboseWebRtcLog = DeviceFeatureAdapter.verboseWebRtcLog;
    _dumpSrtpPackets = DeviceFeatureAdapter.dumpSrtpPackets;
    _iceGatheringContinually = DeviceFeatureAdapter.iceGatheringContinually;
    _useMulticast = context.read<AppSettings>().useMulticast;
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _roomNumberController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: '請輸入樓層/會議室編號',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _onSaveRoomNumber,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Show Debug Overlay'),
                          value: _showDebugOverlay,
                          onChanged: _showDebugOverlayChanged,
                        ),
                        SwitchListTile(
                          title: const Text('Show Device Info Overlay'),
                          value: _showDeviceInfoOverlay,
                          onChanged: _showDeviceInfoOverlayChanged,
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
                        SwitchListTile(
                          title: const Text('Multicast'),
                          value: _useMulticast,
                          onChanged: (value) => _changeMulticast(value),
                        ),
                        const _CastingTimeAdjuster(),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Upload log
                              final result = await uploadSystemLog('log');

                              if (!context.mounted) return;

                              MotionToast.success(
                                description: Text(
                                  result
                                      ? "Logs uploaded successfully"
                                      : "Log upload failed",
                                ),
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
                        const SizedBox(height: 8),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              throw Exception(
                                  'Sentry Test Error from Debug Switch');
                            },
                            child: const Text(
                              'Send Sentry Test Error',
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

class _CastingTimeAdjuster extends StatefulWidget {
  const _CastingTimeAdjuster();

  @override
  State<_CastingTimeAdjuster> createState() => _CastingTimeAdjusterState();
}

class _CastingTimeAdjusterState extends State<_CastingTimeAdjuster> {
  late int currentMinutes;
  Timer? _timer;
  static const int stepMinutes = 5;
  static const int minMinutes = 10;
  static const int maxMinutes = 180;

  @override
  void initState() {
    super.initState();
    currentMinutes = ConnectionTimer.threeHourTimeLimitSec ~/ 60;
  }

  void _updateConnectionTimer() {
    ConnectionTimer.threeHourTimeLimitSec = currentMinutes * 60;
  }

  void _increment() {
    if (!mounted) return;
    setState(() {
      if (currentMinutes + stepMinutes <= maxMinutes) {
        currentMinutes += stepMinutes;
        _updateConnectionTimer();
      }
    });
  }

  void _decrement() {
    if (!mounted) return;
    setState(() {
      if (currentMinutes - stepMinutes >= minMinutes) {
        currentMinutes -= stepMinutes;
        _updateConnectionTimer();
      }
    });
  }

  void _startTimer(VoidCallback action) {
    action();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      action();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Casting Time Limit'),
          const Spacer(),
          GestureDetector(
            onTap: _decrement,
            onLongPressStart: (_) => _startTimer(_decrement),
            onLongPressEnd: (_) => _stopTimer(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, size: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              '${(currentMinutes ~/ 60).toString().padLeft(1, '0')} h '
              '${(currentMinutes % 60).toString().padLeft(2, '0')} m',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: _increment,
            onLongPressStart: (_) => _startTimer(_increment),
            onLongPressEnd: (_) => _stopTimer(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 15),
            ),
          ),
        ],
      ),
    );
  }
}
