import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:flutter/material.dart';

class V3ExitDialog extends StatefulWidget {
  const V3ExitDialog({super.key});

  @override
  State<StatefulWidget> createState() => _V3ExitDialogState();
}

class _V3ExitDialogState extends State<V3ExitDialog> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(S.of(context).v3_exit_title),
        actions: [
          V3Focus(
            label: S.of(context).v3_lbl_exit_action_exit,
            identifier: 'v3_qa_exit_action_exit',
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                side: BorderSide(
                    color: context.tokens.color.vsdswColorPrimary, width: 1),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
              ),
              child: Text(S.of(context).v3_exit_action_exit),
            ),
          ),
          V3Focus(
            label: S.of(context).v3_lbl_exit_action_cancel,
            identifier: 'v3_qa_exit_action_cancel',
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: ElevatedButton.styleFrom(
                elevation: 5.0,
                shadowColor: context.tokens.color.vsdswColorPrimary,
                foregroundColor: context.tokens.color.vsdswColorOnPrimary,
                backgroundColor: context.tokens.color.vsdswColorPrimary,
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(S.of(context).v3_exit_action_cancel),
            ),
          ),
        ],
      ),
    );
  }
}
