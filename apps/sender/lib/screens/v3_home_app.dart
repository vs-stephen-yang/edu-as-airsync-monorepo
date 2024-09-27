import 'package:display_cast_flutter/widgets/v3_background.dart';
import 'package:flutter/material.dart';

class V3HomeApp extends StatelessWidget {
  const V3HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const V3Background(),
        ],
      ),
    );
  }
}
