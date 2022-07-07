import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:flutter/material.dart';

class PrivilegeMessage extends StatelessWidget {
  const PrivilegeMessage({Key? key}) : super(key: key);
  static ValueNotifier<bool> showPrivilegeMessage = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showPrivilegeMessage,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width / 3,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: AppColors.primary_dialog,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: AutoSizeText(
                    'Insufficient privilege for Display Advanced. Please contact your IT administrator.',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showPrivilegeMessage.value = false;
                  },
                  child: const AutoSizeText(
                    'Close',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    onPrimary: AppColors.neutral1,
                    primary: Colors.white,
                    minimumSize: const Size(80, 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
