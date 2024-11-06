import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/widgets/present_timer.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentPresentStartDemo extends StatelessWidget {
  PresentPresentStartDemo({super.key});

  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    DemoProvider demoProvider = Provider.of<DemoProvider>(context);
    var textStyle30 = const TextStyle(color: Colors.white, fontSize: 28);
    return Column(
      children: [
        const Expanded(flex: 2, child: SizedBox()),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Text(
            S.of(context).present_time,
            style: textStyle30,
          ),
        ),
        const PresentTimer(),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: ValueListenableBuilder(
                    valueListenable: presentingState,
                    builder: (BuildContext context, value, Widget? child) {
                      return InkWell(
                        onTap: () {
                          presentingState.value = !presentingState.value;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              value
                                  ? Icons.pause_presentation
                                  : Icons.smart_display_outlined,
                              color: Colors.white,
                            ),
                            const Padding(padding: EdgeInsets.only(left: 8)),
                            Text(
                              value
                                  ? S.of(context).present_state_pause
                                  : S.of(context).present_state_resume,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 38.0, top: 20.0),
                  child: InkWell(
                    onTap: () {
                      demoProvider.isDemoMode = false;
                      demoProvider.presentDemoOff();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cancel_presentation,
                          color: Colors.white,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 8)),
                        Text(
                          S.of(context).present_state_stop,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
