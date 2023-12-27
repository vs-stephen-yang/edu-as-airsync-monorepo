
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/main_info_net.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainInternetMode extends StatelessWidget{
  const MainInternetMode({super.key});

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
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
                      'Internet mode',
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
                const Padding(
                  padding: EdgeInsets.only(top: runSpacing, bottom: 20),
                  child: Divider(color: Colors.white,),
                ),
                const Text(
                  'Please go to this URL to cast your  ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: runSpacing),
                ),
                FittedBox(
                  child: Text(
                    appConfig?.settings.mainDisplayUrl ?? ' ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/ic_main_net.png',
                          height: 18,
                          color: Colors.blueAccent,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 10)),
                        const Text(
                          'Internet mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(left: runSpacing)),
                    InkWell(
                      onTap: () {
                        channelProvider.currentMode = Mode.lan;
                      },
                      child: const Row(
                        children: [
                        Icon(Icons.lan_outlined, size: 23, color: Colors.white,),
                          Padding(padding: EdgeInsets.only(left: 10)),
                          Text(
                            'Lan mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
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
            child: MainInfoInternet(),
          )
          // const Expanded(flex: 2, child: MainInfo()),
        ],
      ),
    );
  }
  
}