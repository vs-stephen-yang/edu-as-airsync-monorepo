import 'dart:async';

import 'package:display_cast_flutter/widgets/custom_icons.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:flutter/material.dart';

class PresentWaitReady extends StatefulWidget {
  const PresentWaitReady({super.key});

  @override
  State<PresentWaitReady> createState() => _PresentWaitReadyState();
}

class _PresentWaitReadyState extends State<PresentWaitReady> with TickerProviderStateMixin  {
  final ValueNotifier<int> _countDownValue = ValueNotifier(30);

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _countDownValue.value = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _countDownValue.value--;
      if (_countDownValue.value.isNegative) {
        timer.cancel();
      }
    });
    return SizedBox(
      width: 300,
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TitleBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
            child: RotationTransition(
              turns: _animation,
              child: const Icon(
                CustomIcons.loading,
                color: Colors.white,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _countDownValue,
            builder: (context, int value, child) {
              return Text(
                'Please select to share screen in $value seconds.',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
