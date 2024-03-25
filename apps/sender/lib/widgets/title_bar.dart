import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      width: 300,
      child: Row(
        children: [
          Image.asset(
            'assets/images/ic_launcher.png',
            height: 46,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'AirSync',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5.0)),
        ],
      ),
    );
  }
}
