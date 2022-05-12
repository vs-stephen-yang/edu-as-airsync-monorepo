import 'package:display_flutter/widgets/left_panels.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';

class WhatsNew extends StatefulWidget {
  const WhatsNew({Key? key}) : super(key: key);

  @override
  _WhatsNewState createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew> {
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
                      LeftPanels.showWhatsNew.value = false;
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
                      "What’s New on Display?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary_white),
                    ),
                  ),
                )),
              ],
            ),
          ),
          const RawScrollbar(
            isAlwaysShown: true,
            thumbColor: AppColors.primary_white,
            child: SingleChildScrollView(
              child: Text(
                "",
                style: TextStyle(color: AppColors.primary_white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
