import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';

class V3DialogActionButtons extends StatefulWidget {
  final V3ButtonInfo leftButton;
  final V3ButtonInfo rightButton;
  final double spacing;

  const V3DialogActionButtons({
    super.key,
    required this.leftButton,
    required this.rightButton,
    this.spacing = 6,
  });

  @override
  State<V3DialogActionButtons> createState() => _V3DialogActionButtonsState();
}

class _V3DialogActionButtonsState extends State<V3DialogActionButtons> {
  bool _shouldWrap = false;
  final GlobalKey _rowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkWrap());
  }

  void _checkWrap() {
    final context = _rowKey.currentContext;
    if (context != null) {
      final height = context.size?.height ?? 0;
      if (height > 40 && !_shouldWrap) {
        if (!mounted) return;
        setState(() => _shouldWrap = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final left = _buildButton(widget.leftButton);
    final right = _buildButton(widget.rightButton);

    if (_shouldWrap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: left,
          ),
          SizedBox(height: widget.spacing),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: right,
          ),
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Row(
        key: _rowKey,
        children: [
          Expanded(child: left),
          SizedBox(width: widget.spacing),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _buildButton(V3ButtonInfo info) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 40), // 關鍵保持高度
      child: V3Focus(
        label: info.label,
        identifier: info.identifier,
        child: InkWell(
          onTap: info.onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: ShapeDecoration(
              color: info.backgroundColor,
              shape: RoundedRectangleBorder(
                side: info.borderColor != null
                    ? BorderSide(width: 2, color: info.borderColor!)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Center(
              child: V3AutoHyphenatingText(
                info.text,
                textAlign: TextAlign.center,
                // softWrap: true,
                // overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: info.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class V3ButtonInfo {
  final String text;
  final String? label;
  final String? identifier;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? shadowColor;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const V3ButtonInfo({
    required this.text,
    required this.label,
    required this.identifier,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.shadowColor,
    this.focusNode,
    this.padding,
    this.textStyle,
  });
}
