import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class Eula extends StatefulWidget {
  const Eula({super.key});

  @override
  State createState() => _EulaState();
}

class _EulaState extends State<Eula> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(35, 35, 35, 15),
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF383838),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        S.of(context).eula_title,
                        style: const TextStyle(
                          color: Color(0xFF2979FF),
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: FutureBuilder<String>(
                          future: _loadEulaFromAssets(),
                          builder: (context, snapshot) {
                            String content;
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null) {
                              content = snapshot.data as String;
                            } else {
                              content = S.of(context).eula_title;
                            }
                            return FocusSingleChildScrollView(
                              textContent: content,
                              textColor: const Color(0xFFF7F7F7),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: <Widget>[
              FocusElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white,
                ),
                hasFocusWidth: 140,
                notFocusWidth: 130,
                hasFocusHeight: 55,
                notFocusHeight: 48,
                onClick: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  } else {
                    // todo: support other platform.
                  }
                },
                child: AutoSizeText(
                  S.of(context).eula_disagree,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                  maxLines: 1,
                ),
              ),
              FocusElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.blue,
                ),
                hasFocusWidth: 140,
                notFocusWidth: 130,
                hasFocusHeight: 55,
                notFocusHeight: 48,
                onClick: () {
                  AppPreferences().set(showEULA: false);
                  navService.pushNamedAndRemoveUntil('/v3Home');
                },
                child: AutoSizeText(
                  S.of(context).eula_agree,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const BottomBar(),
        ],
      ),
    );
  }

  Future<String> _loadEulaFromAssets() async {
    return await rootBundle
        .loadString('assets/ViewSonic-MVB-EULA-20230508.txt');
  }
}
