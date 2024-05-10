import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 30,
      bottom: 30,
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/ic_logo_build_by.png',
            width: 150,
            // height: 88,
          ),
        ],
      ),
    );
  }
}
