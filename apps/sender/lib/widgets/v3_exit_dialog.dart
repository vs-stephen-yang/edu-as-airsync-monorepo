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
        backgroundColor: context.tokens.color.vsdswColorSurface100,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: V3Focus(
                identifier: 'v3_exit_close',
                child: IconButton(
                  iconSize: 12,
                  icon: Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: context.tokens.spacing.vsdswSpacingMd.top),
              child: Center(
                // Can not use V3AutoHyphenatingText
                child: Text(
                  S.of(context).v3_exit_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.tokens.color.vsdswColorOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: context.tokens.textStyle.vsdswHeadingMd.fontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 436,
          height: 128,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Divider(),
            ],
          ),
        ),
        actions: [
          _updateDialogButton(
            label: S.of(context).v3_lbl_exit_action_exit,
            identifier: 'v3_qa_exit_action_exit',
            text: S.of(context).v3_exit_action_exit,
            textColor: context.tokens.color.vsdswColorSecondary,
            backgroundColor: Colors.transparent,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          _updateDialogButton(
            label: S.of(context).v3_lbl_exit_action_cancel,
            identifier: 'v3_qa_exit_action_cancel',
            text: S.of(context).v3_exit_action_cancel,
            textColor: context.tokens.color.vsdswColorOnPrimary,
            backgroundColor: context.tokens.color.vsdswColorPrimary,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
  }

  Widget _updateDialogButton(
      {required String text,
      required Color textColor,
      required Color backgroundColor,
      required String label,
      required String identifier,
      required GestureTapCallback onPressed}) {
    return V3Focus(
      label: label,
      identifier: identifier,
      child: Material(
        color: Colors.transparent,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: backgroundColor == Colors.transparent ? 0 : 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            shadowColor: backgroundColor.withValues(alpha: 0.31),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
