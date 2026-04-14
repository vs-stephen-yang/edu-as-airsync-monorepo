import 'package:display_flutter/widgets/base_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';

class V3FocusSingleChildScrollView extends StatelessWidget {
  const V3FocusSingleChildScrollView({
    super.key,
    this.children = const <Widget>[],
    this.primaryFocusNode,
  });

  final List<Widget> children;
  final FocusNode? primaryFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseFocusSingleChildScrollView(
      focusNode: primaryFocusNode,
      children: children,
    );
  }
}
