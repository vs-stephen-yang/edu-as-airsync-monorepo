import 'dart:async';

import 'package:flutter/material.dart';

class PresentWaitReady extends StatelessWidget {
  PresentWaitReady({super.key});

  final ValueNotifier<int> _countDownValue = ValueNotifier(30);

  @override
  Widget build(BuildContext context) {
    _countDownValue.value = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _countDownValue.value--;
      if (_countDownValue.value.isNegative) {
        timer.cancel();
      }
    });
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder(
          valueListenable: _countDownValue,
          builder: (context, int value, child) {
            return Text(
              'Please select to share screen in $value seconds.',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            );
          },
        ),
      ],
    );
  }
}
