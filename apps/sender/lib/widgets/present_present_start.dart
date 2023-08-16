import 'dart:async';

import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentPresentStart extends StatelessWidget {
  PresentPresentStart({super.key});

  final ValueNotifier<int> _countSecondsValue = ValueNotifier(0);
  final ValueNotifier<int> _countMinutesValue = ValueNotifier(0);
  final ValueNotifier<int> _countHoursValue = ValueNotifier(0);

  final ValueNotifier<bool> _presentingState = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider = Provider.of<PresentStateProvider>(context);
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

    var textStyle20 = const TextStyle(color: Colors.white, fontSize: 16);
    var textStyle30 = const TextStyle(color: Colors.white, fontSize: 20);
    return SizedBox(
      width: 300,
      height: 400,
      child: Column(
        children: [
          const TitleBar(),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 30),
            child: Text(
              'Presentation time',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Divider(color: Colors.white12,),
          ),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _presentingState,
                  builder: (BuildContext context, value, Widget? child) {
                    return InkWell(
                      onTap: () {
                        _presentingState.value = !_presentingState.value;
                        if (_presentingState.value) {
                          presentStateProvider.presentResume();
                        } else {
                          presentStateProvider.presentPause();
                        }
                      },
                      child: Column(
                        children: [
                          Icon(
                            value
                                ? Icons.pause_presentation
                                : Icons.smart_display_outlined,
                            color: Colors.white,
                          ),
                          Text(value ? 'PAUSE' : 'RESUME',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (presentStateProvider.displayer?.property!['platform'] == 'windows')
                Expanded(
                  child: InkWell(
                    onTap: () {
                      presentStateProvider.presentFullscreen();
                    },
                    child: Column(
                      children: [
                        Icon(
                          presentStateProvider.displayer?.windowState == 'normal' ? Icons.fullscreen : Icons.fullscreen_exit,
                          color: Colors.white,
                        ),
                        Text(presentStateProvider.displayer?.windowState == 'normal' ? 'Full screen': 'Exit Full screen',
                            style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    presentStateProvider.presentStop();
                    presentStateProvider.presentEnd();
                  },
                  child: Column(
                    children: const [
                      Icon(Icons.cancel_presentation, color: Colors.white,),
                      Text('Stop Presenting', style: TextStyle(color: Colors.white, fontSize: 10)),
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
