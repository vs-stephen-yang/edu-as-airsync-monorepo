import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PresentTimer extends StatelessWidget {
  PresentTimer(
      {super.key, required this.presentingState, this.countStartTime = 0});

  final ValueNotifier<int> _countSecondsValue = ValueNotifier(0);
  final ValueNotifier<int> _countMinutesValue = ValueNotifier(0);
  final ValueNotifier<int> _countHoursValue = ValueNotifier(0);

  final ValueNotifier<bool> presentingState;
  final int countStartTime;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && countStartTime != 0) {
      final start =
          (DateTime.now().millisecondsSinceEpoch - countStartTime) ~/ 1000;
      _countSecondsValue.value = start % 60;
      _countMinutesValue.value = (start % 3600) ~/ 60;
      _countHoursValue.value = start ~/ 3600;
    } else {
      _countSecondsValue.value = 0;
      _countMinutesValue.value = 0;
      _countHoursValue.value = 0;
    }
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (presentingState.value) {
        _countSecondsValue.value++;
      }
      if (_countSecondsValue.value == 60) {
        _countSecondsValue.value = 0;
        _countMinutesValue.value++;
      }
      if (_countMinutesValue.value == 60) {
        _countMinutesValue.value = 0;
        _countHoursValue.value++;
      }
      if (!context.mounted) {
        timer.cancel();
      }
    });

    var textStyle20 = const TextStyle(color: Colors.white, fontSize: 20);
    var textStyle30 = const TextStyle(color: Colors.white, fontSize: 28);
    return SizedBox(
      width: AppConstants.viewStateMenuWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ValueListenableBuilder(
            valueListenable: _countHoursValue,
            builder: (BuildContext context, int value, Widget? child) {
              return Text(
                value.toString().padLeft(2, '0'),
                style: textStyle30,
              );
            },
          ),
          Text(S.of(context).present_time_unit_hour, style: textStyle20),
          Text(':', style: textStyle30),
          ValueListenableBuilder(
            valueListenable: _countMinutesValue,
            builder: (BuildContext context, int value, Widget? child) {
              return Text(
                value.toString().padLeft(2, '0'),
                style: textStyle30,
              );
            },
          ),
          Text(S.of(context).present_time_unit_min, style: textStyle20),
          Text(':', style: textStyle30),
          ValueListenableBuilder(
            valueListenable: _countSecondsValue,
            builder: (BuildContext context, int value, Widget? child) {
              return Text(
                value.toString().padLeft(2, '0'),
                style: textStyle30,
              );
            },
          ),
          Text(S.of(context).present_time_unit_sec, style: textStyle20),
        ],
      ),
    );
  }
}
