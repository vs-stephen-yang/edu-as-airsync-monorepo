import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/widgets/v3_text_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3Status extends StatefulWidget {
  const V3Status({super.key});

  @override
  State<StatefulWidget> createState() => _V3StatusState();
}

class _V3StatusState extends State<V3Status> {
  ConnectivityResult _lastConnectivityResult = ConnectivityResult.none;
  static const platform =
      MethodChannel('com.mvbcast.crosswalk/wifi_signal_strength');
  int _signalStrength = -1;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _getWifiSignalStrength();
  }

  @override
  Widget build(BuildContext context) {
    String networkIconName;
    if (_lastConnectivityResult == ConnectivityResult.wifi) {
      // todo: fine tune threshold 0~99.
      if (_signalStrength >= 80) {
        networkIconName = 'ic_network_wifi_high.svg';
      } else if (_signalStrength >= 30) {
        networkIconName = 'ic_network_wifi_middle.svg';
      } else {
        networkIconName = 'ic_network_wifi_low.svg';
      }
    } else if (_lastConnectivityResult == ConnectivityResult.ethernet) {
      networkIconName = 'ic_network_ethernet.svg';
    } else {
      networkIconName = 'ic_network_disconnect.svg';
    }
    return Row(
      children: [
        Image(
          image: const Svg('assets/images/ic_screen.svg'),
          width: 27,
          height: 27,
          color: context.tokens.color.vsdslColorOnSurface,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Consumer<InstanceInfoProvider>(
            builder: (_, provider, __) {
              return Text(
                provider.deviceName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.tokens.color.vsdslColorOnSurface,
                ),
              );
            },
          ),
        ),
        Image(
          image: Svg('assets/images/$networkIconName'),
          height: 27,
          width: 27,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 1,
            height: 27,
            color: context.tokens.color.vsdslColorOutlineVariant,
          ),
        ),
        const V3TextClock(),
      ],
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    Connectivity().onConnectivityChanged.listen((result) async {
      setState(() {
        _lastConnectivityResult = result;
      });
    });
  }

  Future<void> _getWifiSignalStrength() async {
    int signalStrength;
    try {
      signalStrength = await platform.invokeMethod('getWifiSignalStrength');
      log('Wifi signalStrength: $signalStrength');
    } on PlatformException catch (e) {
      signalStrength = -1;
      log("Failed to get Wi-Fi signal strength: '${e.message}'.");
    }

    setState(() {
      _signalStrength = signalStrength;
    });
  }
}
