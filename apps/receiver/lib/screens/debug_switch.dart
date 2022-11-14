import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/focus_text_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class DebugSwitch extends StatefulWidget {
  const DebugSwitch({Key? key}) : super(key: key);

  @override
  State createState() => _DebugSwitchState();
}

class _DebugSwitchState extends State<DebugSwitch> {
  static const _debugSwitch =
      MethodChannel('com.mvbcast.crosswalk/debug_switch');

  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: AppColors.primary_grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: FocusIconButton(
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary_white,
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: () {
                        navService.popUntil('/home');
                      },
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
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
          ),
          Flexible(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: FocusTextButton(
                child: const Text('-- Toggle webrtc logger panel --',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary_blue,
                    )),
                onClick: () {
                  _debugSwitch.invokeMethod('toggleDebugInfoVisible');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
