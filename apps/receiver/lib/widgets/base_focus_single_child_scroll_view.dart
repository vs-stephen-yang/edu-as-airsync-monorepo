import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseFocusSingleChildScrollView extends StatefulWidget {
  const BaseFocusSingleChildScrollView({
    super.key,
    required this.children,
    this.focusNode,
    this.onKeyEvent,
  });

  final List<Widget> children;

  final FocusNode? focusNode;

  final KeyEventResult Function(FocusNode node, KeyEvent event)? onKeyEvent;

  @override
  State<BaseFocusSingleChildScrollView> createState() =>
      _BaseFocusSingleChildScrollViewState();
}

class _BaseFocusSingleChildScrollViewState
    extends State<BaseFocusSingleChildScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _defaultOnKeyEvent(FocusNode node, KeyEvent event) {
    if (!_scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    final double offset = _scrollController.offset;
    final position = _scrollController.position;

    if (offset > position.minScrollExtent &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _scrollController.animateTo(
        offset - 100,
        duration: const Duration(milliseconds: 30),
        curve: Curves.ease,
      );
      return KeyEventResult.handled;
    } else if (offset < position.maxScrollExtent &&
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _scrollController.animateTo(
        offset + 100,
        duration: const Duration(milliseconds: 30),
        curve: Curves.ease,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (widget.onKeyEvent != null) {
          final result = widget.onKeyEvent!(node, event);
          if (result != KeyEventResult.ignored) {
            return result;
          }
        }

        return _defaultOnKeyEvent(node, event);
      },
      child: Builder(
        builder: (context) {
          final FocusNode focusNode = Focus.of(context);
          final bool hasFocus = focusNode.hasFocus;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 可捲動區塊
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
              // 焦點邊框
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
        },
      ),
    );
  }
}
