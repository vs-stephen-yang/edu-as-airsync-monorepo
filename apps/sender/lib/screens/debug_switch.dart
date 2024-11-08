import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/app_preferences.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/profile_util.dart';
import 'package:display_cast_flutter/utilities/share_log.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_cast_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';

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
  int _maxBitrateKbps = 0;
  int _minBitrateKbps = 0;

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

  void _changeLogVerbose(bool value) async {
    setLogLevelVerbose(value);

    setState(() {
      _isLogVerbose = value;
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
                    SwitchListTile(
                        title: const Text('show old UI'),
                        value: _showOldUI,
                        onChanged: _showOldUIChanged),
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
