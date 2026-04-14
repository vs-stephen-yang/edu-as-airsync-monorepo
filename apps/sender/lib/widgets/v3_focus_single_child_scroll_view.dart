import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class V3FocusSingleChildScrollView extends StatefulWidget {
  const V3FocusSingleChildScrollView({
    super.key,
    this.children = const <Widget>[],
    this.thumbColor,
  });

  final List<Widget> children;
  final Color? thumbColor;

  @override
  State<StatefulWidget> createState() => _V3FocusSingleChildScrollViewStage();
}

class _V3FocusSingleChildScrollViewStage
    extends State<V3FocusSingleChildScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: V3Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thumbColor: widget.thumbColor,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
      onKeyEvent: (FocusNode node, KeyEvent event) {
        double offset = _scrollController.offset;
        if (offset > _scrollController.position.minScrollExtent &&
            event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _scrollController.animateTo(offset - 100,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        } else if (offset < _scrollController.position.maxScrollExtent &&
            event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _scrollController.animateTo(offset + 100,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  }
}
