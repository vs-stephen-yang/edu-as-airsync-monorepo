import 'package:flutter/material.dart';

import '../app_colors.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({Key? key}) : super(key: key);

  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  final List<String> languages = <String>['English', 'Chinese'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: AppColors.primary_grey,
          // Displays().getSelectedDisplay().presenterIndex == -1
          //   ? AppColors.primary_grey
          //   : AppColors.primary_grey_tran,
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.12,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                      child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.primary_white),
                      onPressed: () {
                        // if (MyApp.bIsEmbedded) {
                        //   MyApp.methodChannel.invokeMethod("hide");
                        // }
                      },
                    ),
                  )),
                  const Expanded(
                      flex: 9,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          "Language",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary_white),
                        ),
                      )),
                ],
              ),
            ),
            ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: languages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: AppColors.primary_grey_dark,
                      ),
                      child: Text(languages[index],
                          style: TextStyle(color: AppColors.primary_white)));
                })
          ],
        ),
      ),
    );
  }
}
