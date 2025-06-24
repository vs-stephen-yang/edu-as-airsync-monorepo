import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.description,
    required this.positiveButton,
    required this.onPositive,
    required this.onNegative,
  });

  final String title, description, positiveButton;
  final VoidCallback onPositive, onNegative;

  @override
  State createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: AppColors.primaryDialog,
      alignment: MediaQuery.of(context).orientation == Orientation.portrait
          ? const Alignment(-1.0, 0.5)
          : Alignment.centerLeft,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 0.40
                : 0.25),
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              V3AutoHyphenatingText(
                widget.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FocusElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                    ),
                    hasFocusWidth: 120,
                    notFocusWidth: 110,
                    hasFocusHeight: 30,
                    notFocusHeight: 25,
                    onClick: () {
                      widget.onNegative.call();
                      navService.goBack();
                    },
                    child: V3AutoHyphenatingText(
                      S.of(context).moderator_cancel,
                      style: const TextStyle(color: AppColors.primaryGrey),
                    ),
                  ),
                  FocusElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      backgroundColor: AppColors.primaryRed,
                    ),
                    hasFocusWidth: 120,
                    notFocusWidth: 110,
                    hasFocusHeight: 30,
                    notFocusHeight: 25,
                    onClick: () {
                      navService.goBack();
                      widget.onPositive.call();
                    },
                    child: V3AutoHyphenatingText(
                      widget.positiveButton,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
