import 'dart:io';

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VbsOTA extends StatefulWidget {
  const VbsOTA({super.key});

  @override
  State createState() => _VbsOTAState();
}

class _VbsOTAState extends State<VbsOTA> {
  static const _vbsOTA = MethodChannel('com.mvbcast.crosswalk/vbs_ota');
  static const _autoStartUp =
      MethodChannel('com.mvbcast.crosswalk/auto_startup');

  late FocusNode _focusNode;
  bool _systemOTAEnableUI = false;
  int _downloadProgress = 0;

  Future<bool> _getAutoStartUpSettings() async {
    return await _autoStartUp
        .invokeMethod('getAutoStartupValue', <String, dynamic>{});
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _vbsOTA.setMethodCallHandler((call) async {
      if (call.method == 'setSystemOTAEnableUI') {
        setState(() {
          _systemOTAEnableUI = call.arguments as bool;
        });
      } else if (call.method == 'setDownloadProgress') {
        setState(() {
          _downloadProgress = call.arguments as int;
        });
      }
    });
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: <Widget>[
              FutureBuilder(
                future: _getAutoStartUpSettings(),
                builder: (context, snapshot) {
                  return Focus(
                    canRequestFocus: false,
                    child: Builder(
                      builder: (context) {
                        final FocusNode focusNode = Focus.of(context);
                        final bool hasFocus = focusNode.hasFocus;
                        return Transform.scale(
                          scale: hasFocus ? 1.4 : 1.0,
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Checkbox(
                              side: WidgetStateBorderSide.resolveWith(
                                  (states) =>
                                      const BorderSide(color: Colors.white)),
                              value: (snapshot.hasData)
                                  ? snapshot.data as bool
                                  : null,
                              tristate: true,
                              onChanged: (bool? value) {
                                setState(() {
                                  _autoStartUp.invokeMethod(
                                      'setAutoStartupValue',
                                      <String, dynamic>{'startup': value});
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              V3AutoHyphenatingText(
                S.of(context).main_auto_startup,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          if (AppInstanceCreate().isInstalledInVBS100)
            Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: <Widget>[
                FocusIconButton(
                  icons: Icons.power_settings_new,
                  iconForegroundColor: AppColors.iconStandbyForeground,
                  iconBackgroundColor: AppColors.iconStandbyBackground,
                  hasFocusSize: AppUIConstant.iconHasFocusSize,
                  notFocusSize: AppUIConstant.iconNotFocusSize,
                  onClick: () {
                    Process.run('reboot', <String>[]);
                  },
                ),
                if (_systemOTAEnableUI)
                  IntrinsicWidth(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        V3AutoHyphenatingText(
                          S.of(context).vbs_ota_progress_msg,
                          style: const TextStyle(fontSize: 10),
                        ),
                        SizedBox(
                          height: 20,
                          child: Center(
                            child: LinearProgressIndicator(
                              value: (_downloadProgress / 100),
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
