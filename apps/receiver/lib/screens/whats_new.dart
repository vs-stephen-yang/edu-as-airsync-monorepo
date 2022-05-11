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
                          "What’s New on Display?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary_white),
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
                  "Test",
                  style: TextStyle(color: AppColors.primary_white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
