import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class MenuDialog extends StatelessWidget {
  const MenuDialog(
      {super.key,
      this.backgroundColor,
      this.alignment = Alignment.bottomLeft,
      this.edgeInsets = const EdgeInsets.fromLTRB(20, 0, 0, 140),
      this.menuSize,
      this.topTitleText,
      this.topTitleAction,
      this.content,
      this.bottomAction});

  final Color? backgroundColor;
  final AlignmentGeometry? alignment;
  final EdgeInsets? edgeInsets;
  final Size? menuSize;
  final String? topTitleText; // Title text in menu top area.
  final Widget? topTitleAction; // Action items behind title text.
  final Widget? content; // Main content items
  final Widget? bottomAction; // Action items in menu bottom area.

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: backgroundColor,
      alignment: alignment,
      insetPadding: edgeInsets,
      child: SizedBox(
        width: menuSize != null
            ? menuSize!.width
            : MediaQuery.of(context).size.width *
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 0.45
                    : 0.25),
        height: menuSize != null
            ? menuSize!.height
            : MediaQuery.of(context).size.height *
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 0.35
                    : 0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (bottomAction == null)
              Expanded(
                flex: 1,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: <Widget>[
                      FittedBox(
                        fit: BoxFit.fitHeight,
                        child: FocusIconButton(
                          childNotFocus: const Icon(
                            Icons.arrow_back_ios_new,
                          ),
                          splashRadius: 20,
                          focusColor: Colors.grey,
                          onClick: () {
                            navService.goBack();
                          },
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: V3AutoHyphenatingText(
                              topTitleText ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      topTitleAction ?? const SizedBox(),
                    ],
                  ),
                ),
              ),
            Expanded(
              flex: 7,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: content ?? const SizedBox(),
              ),
            ),
            if (bottomAction != null)
              Expanded(
                flex: 1,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: bottomAction,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
