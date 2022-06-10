import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Image.asset(
                'assets/images/ic_logo_my_viewboard.png',
                width: 276,
                height: 78,
              ),
              Image.asset(
                'assets/images/ic_logo_build_by.png',
                width: 234,
                height: 88,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
