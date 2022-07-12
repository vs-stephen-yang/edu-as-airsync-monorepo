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
  bool _systemOTAEnableUI = false;
  int _downloadProgress = 0;

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
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: <Widget>[
              const Image(
                  image: Svg('assets/images/ic_power_settings.svg',
                      size: Size.square(48))),
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
