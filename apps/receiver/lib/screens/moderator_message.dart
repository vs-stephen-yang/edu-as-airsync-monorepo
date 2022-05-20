import 'package:display_flutter/app_colors.dart';
import 'package:flutter/material.dart';

class ModeratorMessage {
  static showSnackMessage(
      BuildContext context, bool isSuccess, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: (isSuccess
                    ? Icon(Icons.done_all, color: Colors.white)
                    : Icon(Icons.info_outline, color: Colors.white))),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.semantic1 : AppColors.semantic2,
        padding: const EdgeInsets.all(8.0),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
