import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
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
      backgroundColor: AppColors.primary_dialog,
      alignment: Alignment.centerLeft,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                    child: AutoSizeText(
                      S.of(context).moderator_cancel,
                      style: const TextStyle(color: AppColors.primary_grey),
                    ),
                  ),
                  FocusElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primary_red,
                      backgroundColor: AppColors.primary_red,
                    ),
                    hasFocusWidth: 120,
                    notFocusWidth: 110,
                    hasFocusHeight: 30,
                    notFocusHeight: 25,
                    onClick: () {
                      navService.goBack();
                      widget.onPositive.call();
                    },
                    child: AutoSizeText(
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
