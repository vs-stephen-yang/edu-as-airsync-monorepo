import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusSingleChildScrollView extends StatefulWidget {
  const FocusSingleChildScrollView({
    super.key,
    required this.textContent,
    this.textColor,
  });

  final String textContent;
  final Color? textColor;

  @override
  State createState() => _FocusSingleChildScrollViewState();
}

class _FocusSingleChildScrollViewState
    extends State<FocusSingleChildScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thumbColor: Colors.white,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(5),
          child: V3AutoHyphenatingText(
            widget.textContent,
            style: TextStyle(
              color: widget.textColor ?? Colors.white,
            ),
          ),
        ),
      ),
      onKeyEvent: (FocusNode node, KeyEvent event) {
        double offset = _scrollController.offset;
        if (offset > _scrollController.position.minScrollExtent &&
            event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _scrollController.animateTo(offset - 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        } else if (offset < _scrollController.position.maxScrollExtent &&
            event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _scrollController.animateTo(offset + 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  }
}
