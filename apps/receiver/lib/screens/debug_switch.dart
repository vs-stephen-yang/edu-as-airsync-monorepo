import 'package:display_flutter/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugSwitch extends StatefulWidget {
  const DebugSwitch({Key? key}) : super(key: key);
  static ValueNotifier<bool> showDebugSwitch = ValueNotifier(false);

  @override
  State createState() => _DebugSwitchState();
}

class _DebugSwitchState extends State<DebugSwitch> {
  static const _debugSwitch = MethodChannel('com.mvbcast.crosswalk/debug_switch');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: DebugSwitch.showDebugSwitch,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 140),
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.25,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: AppColors.primary_grey,
            ),
            child: Column(
              children: [
                Container(
                  // alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.06,
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      FittedBox(
                        fit: BoxFit.fitHeight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primary_white,
                          ),
                          onPressed: () {
                            DebugSwitch.showDebugSwitch.value = false;
                          },
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: const Text(
                              'Debug Switch',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary_white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  color: Colors.transparent,
                  child: TextButton(
                    onPressed: () {
                      _debugSwitch.invokeMethod("toggleDebugInfoVisible");
                    },
                    child: const Text(
                      '-- Toggle webrtc logger panel --',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary_blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
