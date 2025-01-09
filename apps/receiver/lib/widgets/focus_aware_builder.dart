import 'package:flutter/material.dart';

class FocusAwareBuilder extends StatefulWidget {
  final Widget Function(FocusNode primaryFocusNode) builder;
  final FocusNode primaryFocusNode = FocusNode();

  FocusAwareBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<FocusAwareBuilder> createState() => _FocusAwareDialogState();
}

class _FocusAwareDialogState extends State<FocusAwareBuilder> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.primaryFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.primaryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(widget.primaryFocusNode);
  }
}
