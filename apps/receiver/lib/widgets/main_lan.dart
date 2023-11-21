
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_info_lan.dart';

class MainLanMode extends StatelessWidget{
  const MainLanMode({super.key});

  @override
  Widget build(BuildContext context) {
    const double runSpacing = 16.0;
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return SizedBox(
      width: 1000,
      height: 400,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_main_net.png',
                      height: 23,
                    ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    const Text(
                      'Lan mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: runSpacing)),
                const Text(
                  'Lorem ipsum dolor sit ametconsectetur. Augue variusdf condimentum id ut arcu. ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        channelProvider.currentMode = Mode.internet;
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/ic_main_net.png',
                            height: 18,
                            color: Colors.white,
                          ),
                          const Padding(padding: EdgeInsets.only(left: 10)),
                          const Text(
                            'Internet mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(left: runSpacing)),
                    const Row(
                      children: [
                        Icon(Icons.lan_outlined, size: 23, color: Colors.blueAccent,),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        Text(
                          'Lan mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          // const Padding(padding: EdgeInsets.only(right: 50)),
          const Spacer(),
          const SizedBox(
            width: 400,
            child: MainInfoLan(),
          )
          // const Expanded(flex: 2, child: MainInfo()),
        ],
      ),
    );
  }
  
}