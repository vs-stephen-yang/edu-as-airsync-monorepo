import 'package:display_flutter/widgets/left_panels.dart';
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: AppColors.primary_grey,
        //TODO: the color is AppColors.primary_grey_tran during presenting
      ),
      child: Column(
        children: [
          Container(
            // alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.06,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.transparent,
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.primary_white),
                    onPressed: () {
                      LeftPanels.showLanguage.value = false;
                    },
                  ),
                ),
                Expanded(
                    child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: const Text(
                      "Language",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary_white),
                    ),
                  ),
                )),
              ],
            ),
          ),
          Expanded(
              child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: languages.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: AppColors.primary_grey_dark,
                  ),
                  child: Text(languages[index],
                      style: const TextStyle(color: AppColors.primary_white)));
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 10, color: Colors.transparent);
            },
          )),
        ],
      ),
    );
  }
}
