import 'dart:io';

import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class Eula extends StatefulWidget {
  const Eula({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EulaState();
}

class _EulaState extends State<Eula> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(35, 35, 35, 0),
              child: LayoutBuilder(
                builder: (context, constraint) {
                  return Container(
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
                            child: SingleChildScrollView(
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
                                  return Text(
                                    content,
                                    style: const TextStyle(
                                      color: Color(0xFFF7F7F7),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else if (Platform.isIOS) {
                          exit(0);
                        } else {
                          // todo: support other platform.
                        }
                      },
                      child: Text(
                        S.of(context).eula_disagree,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      AppPreferences().set(showEULA: false);
                      navService.pushNamedAndRemoveUntil('/home');
                    },
                    child: Text(
                      S.of(context).eula_agree,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BottomBar(),
        ],
      ),
    );
  }

  Future<String> _loadEulaFromAssets() async {
    return await rootBundle.loadString('assets/ViewSonic-MVB-EULA-2021.txt');
  }
}
