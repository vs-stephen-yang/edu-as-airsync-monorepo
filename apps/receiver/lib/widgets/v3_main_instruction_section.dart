import 'package:display_flutter/widgets/v3_main_instruction_row.dart';
import 'package:display_flutter/widgets/v3_main_miracast_instruction_row.dart';
import 'package:flutter/material.dart';

class V3MainInstructionSection extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;

  const V3MainInstructionSection({
    super.key,
    this.horizontalPadding = 50.0,
    this.verticalPadding = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const V3MainInstructionRow(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: const V3MainMiracastInstructionRow(),
        ),
      ],
    );
  }
}
