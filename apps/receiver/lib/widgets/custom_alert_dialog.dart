import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.positiveButton,
    required this.onPositive,
    required this.onNegative,
  }) : super(key: key);

  final String title, description, positiveButton;
  final VoidCallback onPositive, onNegative;

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: AppColors.primary_dialog,
      alignment: Alignment.centerLeft,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.all(15.0),
        width: MediaQuery.of(context).size.width * 0.2,
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
                Container(
                  width: 80,
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white,
                  ),
                  child: InkWell(
                    onTap: () {
                      widget.onNegative.call();
                      navService.goBack();
                    },
                    child: Center(
                      child: Text(
                        S.of(context).moderator_cancel,
                        style: const TextStyle(color: AppColors.primary_grey),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: AppColors.primary_red,
                  ),
                  child: InkWell(
                    onTap: () {
                      navService.goBack();
                      widget.onPositive.call();
                    },
                    child: Center(
                      child: Text(
                        widget.positiveButton,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
