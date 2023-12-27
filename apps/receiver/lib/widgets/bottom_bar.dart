import 'package:display_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Row(
            mainAxisAlignment: ChannelProvider.isNewUI ? MainAxisAlignment.start: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ChannelProvider.isNewUI ? SizedBox() :Image.asset(
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
