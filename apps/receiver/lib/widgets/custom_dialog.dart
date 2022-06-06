import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';

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
        elevation: 0,
        backgroundColor: AppColors.primary_dialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          margin: EdgeInsets.all(15.0),
          width: MediaQuery.of(context).size.height *0.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${widget.description}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white,
                      ),
                      child: InkWell(
                        onTap: () {
                          widget.onNegative();
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                            S.of(context).moderator_cancel,
                            style: TextStyle(
                              color: AppColors.primary_grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: AppColors.primary_red,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onPositive();
                        },
                        child: Center(
                          child: Text(
                            widget.positiveButton,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}