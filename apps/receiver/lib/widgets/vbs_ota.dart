import 'dart:io';

import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class VbsOTA extends StatefulWidget {
  const VbsOTA({Key? key}) : super(key: key);

  @override
  State createState() => _VbsOTAState();
}

class _VbsOTAState extends State<VbsOTA> {
  static const _vbsOTA = MethodChannel('com.mvbcast.crosswalk/vbs_ota');
  static const _autoStartUp =
      MethodChannel('com.mvbcast.crosswalk/auto_startup');

  bool _systemOTAEnableUI = false;
  int _downloadProgress = 0;

  Future<bool> _getAutoStartUpSettings() async {
    return await _autoStartUp
        .invokeMethod('getAutoStartupValue', <String, dynamic>{});
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
                  return SizedBox(
                    width: 25,
                    height: 25,
                    child: Checkbox(
                      side: MaterialStateBorderSide.resolveWith((states) =>
                          const BorderSide(width: 1.0, color: Colors.white)),
                      value: (snapshot.hasData) ? snapshot.data as bool : null,
                      tristate: true,
                      onChanged: (bool? value) {
                        setState(() {
                          _autoStartUp.invokeMethod('setAutoStartupValue',
                              <String, dynamic>{'startup': value});
                        });
                      },
                    ),
                  );
                },
              ),
              const Text(
                'Execute Display after startup',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: <Widget>[
              IconButton(
                iconSize: 48,
                onPressed: () {
                  Process.run('reboot', <String>[]);
                },
                icon: const Image(
                  image: Svg('assets/images/ic_power_settings.svg'),
                ),
              ),
              Visibility(
                visible: _systemOTAEnableUI,
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        S.of(context).vbs_ota_progress_msg,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
