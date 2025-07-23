import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';

class V3MainInstructionArea extends StatelessWidget {
  final ScrollController scrollController;
  final double leftPadding;
  final double topPadding;

  const V3MainInstructionArea({
    super.key,
    required this.scrollController,
    this.leftPadding = 53.0,
    this.topPadding = 53.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(
        left: leftPadding,
        top: topPadding,
      ),
      child: V3Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          child: const V3Instruction(isCastToDevice: false),
        ),
      ),
    );
  }
}
