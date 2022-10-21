import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class WhatsNew extends StatefulWidget {
  const WhatsNew({Key? key}) : super(key: key);

  @override
  _WhatsNewState createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew> {
  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: ControlSocket().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.transparent,
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: FocusIconButton(
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary_white,
                    ),
                    splashRadius: 20,
                    focusColor: Colors.grey,
                    onClick: () {
                      navService.popUntil('/home');
                    },
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Text(
                        S.of(context).main_whats_new_title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary_white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              child: RawScrollbar(
                isAlwaysShown: true,
                thumbColor: AppColors.primary_white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    S.of(context).main_whats_new_content,
                    style: const TextStyle(
                      color: AppColors.primary_white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
