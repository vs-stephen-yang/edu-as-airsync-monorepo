import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 30,
      top: 30,
      child: Row(
        children: [
          Image.asset(
            'assets/images/ic_launcher.png',
            height: 46,
          ),
          const SizedBox(width: 10),
          const Text(
            'AirSync',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
