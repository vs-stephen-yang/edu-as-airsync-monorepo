

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/device_list_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({super.key});

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList>{

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    DeviceListProvider deviceListProvider = Provider.of<DeviceListProvider>(context, listen: false);
    deviceListProvider.startDiscovery();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        channelProvider.presentMainPage();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const Image(
                      image: Svg('assets/images/ic_device_list.svg'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  S.of(context).main_device_list,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: AppConstants.fontSize_title,
                  ),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Divider(
              color: Colors.white12,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Consumer<DeviceListProvider>(
              builder: (BuildContext context, DeviceListProvider value, Widget? child) {
                return ListView.builder(
                  itemCount: value.devices.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        print('zz Device click');
                      },
                      child: ListTile(
                        title: Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(value.devices[index].name, style: const TextStyle(
                                color: Colors.white,
                              ),),
                            ),
                            const Spacer(),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('IP', style: TextStyle(
                                color: Colors.white,
                              ),),
                            ),
                          ]
                        ),
                        subtitle: Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(value.devices[index].host, style: const TextStyle(
                                color: Colors.white,
                              ),),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(value.devices[index].ip, style: const TextStyle(
                                color: Colors.white,
                              ),),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Divider(
              color: Colors.white12,
            ),
          ),
        ],
      ),
    );
  }
}