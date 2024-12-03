import 'dart:io';

import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/app_preferences.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/profile_util.dart';
import 'package:display_cast_flutter/utilities/share_log.dart';
import 'package:display_cast_flutter/utilities/webrtc_eventlog_manager.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_cast_flutter/widgets/menu_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class DebugSwitch extends StatefulWidget {
  const DebugSwitch({super.key});

  @override
  State createState() => _DebugSwitchState();
}

class _DebugSwitchState extends State<DebugSwitch> {
  bool _showOldUI = false;
  bool _initialized = false;
  bool _isLogVerbose = false;
  bool _iceGatheringContinually = false;
  bool _isVideoQualityFirst = false;
  bool _enableRTCEventLogs = false;
  int _maxBitrateKbps = 0;
  int _minBitrateKbps = 0;
  bool _showDebugOverlay = false;
  String _rtcEventLogsDir = '';
  final ScrollController _scrollController =
      ScrollController(); // 新增 ScrollController

  void _notifyRestart() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Restart the program to apply the changes.")));
  }

  void _showOldUIChanged(bool value) async {
    await AppPreferences().setShowOldUI(value);

    setState(() {
      _showOldUI = value;
      _notifyRestart();
    });
  }

  void _showDebugOverlayChanged(bool value) async {
    setState(() {
      _showDebugOverlay = value;
      _notifyRestart();
    });
  }

  void _changeLogVerbose(bool value) async {
    setLogLevelVerbose(value);

    setState(() {
      _isLogVerbose = value;
    });
  }

  void _changeRTCEventLogs(bool value) async {
    if (kIsWeb) {
      return; // not supported
    }
    String? dir;
    if (value) {
      if (Platform.isIOS) {
        final Directory documentsDirectory =
            await getApplicationDocumentsDirectory();
        dir = documentsDirectory.path;
      } else {
        dir = await FilePicker.platform.getDirectoryPath();
      }
      if (dir == null) {
        // cancel
        value = false;
      }
    }

    setState(() {
      _enableRTCEventLogs = value;
      if (!value) {
        _rtcEventLogsDir = '';
        WebRTCEventlogManager().clearEventLogDir();
      } else if (dir != null) {
        _rtcEventLogsDir = dir;
        WebRTCEventlogManager().setEventLogDir(dir);
      }
    });
  }

  void _changeVideoProfile(bool value) async {
    String selectedProfile;
    if (value) {
      selectedProfile = ProfileStore.videoQualityFirstProfile;
    } else {
      selectedProfile = ProfileStore.videoSmoothnessFirstProfile;
    }
    await ProfileUtil.saveSelectedProfile(selectedProfile);

    setState(() {
      _isVideoQualityFirst = value;
      _notifyRestart();
    });
  }

  void _changeGatheringPolicy(bool value) async {
    await WebRTCUtil.saveIceGatheringContinually(value);

    setState(() {
      _iceGatheringContinually = value;
      _notifyRestart();
    });
  }

  void _initialize(BuildContext context) {
    _showOldUI = AppPreferences().showOldUI;
    _isLogVerbose = isLogLevelVerbose();
    if (!_initialized) {
      final Profile profile =
          AppConfig.of(context)!.profileStore.getSelectedProfile();
      final Preset preset = profile.presets.first;
      _isVideoQualityFirst =
          profile.name == ProfileStore.videoQualityFirstProfile;
      _maxBitrateKbps = preset.parameters.maxBitrateKbps;
      _minBitrateKbps = preset.parameters.minBitrateKbps;
      _iceGatheringContinually = WebRTCUtil.iceGatheringContinually;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 記得在dispose時釋放
    super.dispose();
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
              controller: _scrollController, // 使用 ScrollController
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController, // 這裡也要使用相同的 ScrollController
                child: Column(
                  children: [
                    SwitchListTile(
                        title: const Text('show old UI'),
                        value: _showOldUI,
                        onChanged: _showOldUIChanged),
                    SwitchListTile(
                      title: const Text('Show Debug Overlay'),
                      value: _showDebugOverlay,
                      onChanged: _showDebugOverlayChanged,
                    ),
                    SwitchListTile(
                        title: const Text('video_quality_first'),
                        value: _isVideoQualityFirst,
                        onChanged: _changeVideoProfile),
                    Text(
                      "minBitrateKbps: $_minBitrateKbps",
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    Text("maxBitrateKbps: $_maxBitrateKbps",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.red)),
                    SwitchListTile(
                        title: const Text('ICE Gathering Continually'),
                        value: _iceGatheringContinually,
                        onChanged: _changeGatheringPolicy),
                    SwitchListTile(
                        title: const Text('Verbose Log'),
                        value: _isLogVerbose,
                        onChanged: _changeLogVerbose),
                    SwitchListTile(
                        title: const Text('Enable RTC Event Logs'),
                        value: _enableRTCEventLogs,
                        onChanged: _changeRTCEventLogs),
                    if (_rtcEventLogsDir != '')
                      Text(
                        _rtcEventLogsDir,
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
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
