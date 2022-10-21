import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/focus_text_button.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/text_clock.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FocusTextButton(
                child: Text(
                  'Ver ${appConfig?.appVersion ?? ' '}',
                  style: const TextStyle(
                    color: AppColors.primaryWhiteA50,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onClick:
                    (AppConfig.of(context)?.settings.isDevelopEnvironment ??
                            false)
                        ? () {
                            StreamFunction.showDebugFunction.value =
                                !StreamFunction.showDebugFunction.value;
                          }
                        : null,
              ),
              const TextClock(),
            ],
          ),
          Text(
            appConfig?.settings.mainDisplayUrl ?? ' ',
            style: const TextStyle(
              color: Color(0xFFF7F7F7),
              fontSize: 36,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
