import 'dart:async';

import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class ModeratorPresentStart extends StatelessWidget {
  ModeratorPresentStart({super.key});

  final ValueNotifier<int> _countSecondsValue = ValueNotifier(0);
  final ValueNotifier<int> _countMinutesValue = ValueNotifier(0);
  final ValueNotifier<int> _countHoursValue = ValueNotifier(0);

  final ValueNotifier<bool> _presentingState = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context);
    _countSecondsValue.value = 0;
    _countMinutesValue.value = 0;
    _countHoursValue.value = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_presentingState.value) {
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
    var textStyle30 = const TextStyle(color: Colors.white, fontSize: 30);
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child:Container(
            padding: const EdgeInsets.fromLTRB(0, 40, 30, 0),
            child: ElevatedButton.icon(
              onPressed: () {
                presentStateProvider.presentEnd();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.black,
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                side: const BorderSide(
                    color: Colors.red,
                    width: 1,
                    style: BorderStyle.solid
                ),
              ),
              icon: const Image(image: Svg('assets/images/ic_exit.svg')),
              label: const Text(
                'EXIT',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 400,
            height: 280,
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Presentation time',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: _countHoursValue,
                        builder: (BuildContext context, int value, Widget? child) {
                          return Text(
                            value.toString().padLeft(2, '0'),
                            style: textStyle30,
                          );
                        }),
                    Text('Hour', style: textStyle20),
                    Text(':', style: textStyle30),
                    ValueListenableBuilder(
                        valueListenable: _countMinutesValue,
                        builder: (BuildContext context, int value, Widget? child) {
                          return Text(
                            value.toString().padLeft(2, '0'),
                            style: textStyle30,
                          );
                        }),
                    Text('Min', style: textStyle20),
                    Text(':', style: textStyle30),
                    ValueListenableBuilder(
                        valueListenable: _countSecondsValue,
                        builder: (BuildContext context, int value, Widget? child) {
                          return Text(
                            value.toString().padLeft(2, '0'),
                            style: textStyle30,
                          );
                        }),
                    Text('Sec', style: textStyle20),
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: ValueListenableBuilder(
                    valueListenable: _presentingState,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          _presentingState.value = !_presentingState.value;
                          if(_presentingState.value) {
                            presentStateProvider.presentResume();
                          } else {
                            presentStateProvider.presentPause();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white,
                        ),
                        icon: Icon(
                          value ? Icons.pause_presentation : Icons.slideshow,
                          color: Colors.black,
                        ),
                        label: Text(
                          value ? 'PAUSE' : 'RESUME',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      presentStateProvider.presentStop(moderatorStart: true);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.cancel_presentation,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'STOP PRESENTING',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
