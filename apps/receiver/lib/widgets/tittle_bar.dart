import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/focus_text_button.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/text_clock.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [Row(
          children: [
            Image.asset('assets/images/ic_launcher.png', height: 46,),
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'AirSync',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            FocusTextButton(
              onClick: (AppConfig.of(context)
                  ?.settings
                  .isDevelopEnvironment ??
                  false)
                  ? () {
                String currentState =
                    StreamFunction.streamFunctionState.value;
                StreamFunction.showDebugFunction =
                !StreamFunction.showDebugFunction;
                StreamFunction.streamFunctionState.value = stateMenuOff;
                StreamFunction.streamFunctionState.value = currentState;
              }
                  : null,
              child: Text(
                'Ver ${appConfig?.appVersion ?? ' '}',
                style: const TextStyle(
                  color: AppColors.primaryWhiteA50,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            const TextClock(),
          ],
        )],
      ),
    );
  }
}
