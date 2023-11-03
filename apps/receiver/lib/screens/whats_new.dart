import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/focus_single_child_scroll_view.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class WhatsNew extends StatefulWidget {
  const WhatsNew({super.key});

  @override
  State createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew> {
  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: ControlSocket().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: FocusIconButton(
                      childNotFocus: const Icon(
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
                        margin: const EdgeInsets.symmetric(vertical: 5),
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
          ),
          Expanded(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: FocusSingleChildScrollView(
                  textContent: S.of(context).main_whats_new_content),
            ),
          ),
        ],
      ),
    );
  }
}
