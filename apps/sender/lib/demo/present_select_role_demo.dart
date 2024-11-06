import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';

class PresentSelectRoleDemo extends StatelessWidget {
  const PresentSelectRoleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DemoProvider>(
        builder: (context, demoProvider, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!kIsWeb)
                  InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                              // color: Colors.transparent,
                            ),
                            child: const Image(
                              image: Svg('assets/images/ic_receiver.svg'),
                            )),
                        const Padding(padding: EdgeInsets.all(5)),
                        Text(
                          S.of(context).present_role_receive,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppConstants.fontSizeTitle,
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      demoProvider.presentRemoteScreenDemoPage();
                    },
                  ),
                const Padding(padding: EdgeInsets.all(10)),
                InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            // color: Colors.transparent,
                          ),
                          child: const Image(
                            image: Svg('assets/images/ic_cast_screen.svg'),
                          )),
                      const Padding(padding: EdgeInsets.all(5)),
                      Text(
                        S.of(context).present_role_cast_screen,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeTitle,
                        ),
                      )
                    ],
                  ),
                  onTap: () async {
                    demoProvider.presentBasicStartDemoPage();
                  },
                ),
              ],
            ));
  }
}
