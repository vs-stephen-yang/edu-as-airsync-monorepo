import 'package:flutter/material.dart';

class V3HomeWeb extends StatelessWidget {
  const V3HomeWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          color: Colors.cyan,
        ),
      ],
    );
  }
}
