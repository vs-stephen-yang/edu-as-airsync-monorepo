import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class V3FocusSingleChildScrollView extends StatefulWidget {
  const V3FocusSingleChildScrollView({
    super.key,
    this.children = const <Widget>[],
  });

  final List<Widget> children;

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
      child: Builder(builder: (context) {
        final FocusNode focusNode = Focus.of(context);
        final bool hasFocus = focusNode.hasFocus;
        return Stack(
          fit: StackFit.expand,
          children: [
            RawScrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thumbColor: context.tokens.color.vsdslColorOutline,
              radius: const Radius.circular(5),
              thickness: 2,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    top: 5,
                    right: 10,
                    bottom: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.children,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 5,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      width: 2,
                      color: hasFocus
                          ? context.tokens.color.vsdslColorSecondary
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
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
