import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:flutter/material.dart';

class V3MainInfo extends StatelessWidget {
  const V3MainInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 1065,
      height: 505,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Color(0xFFFFFFFF),
      ),
      child: Row(
        children: [
          const V3Instruction(),
          Container(
            width: 1,
            color: const Color(0xFFE9EAF0),
          ),
        ],
      ),
    );
  }
}
