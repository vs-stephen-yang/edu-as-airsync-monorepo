import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';

class PrivilegeDialog extends StatelessWidget {
  const PrivilegeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: AppColors.primary_dialog,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 2.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: AutoSizeText(
                      S.of(context).main_privilege_message,
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: AutoSizeText(
                  S.of(context).main_privilege_close,
                  style: const TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}
