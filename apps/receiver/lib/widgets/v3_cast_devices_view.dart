import 'package:display_flutter/widgets/v3_cast_device_list.dart';
import 'package:flutter/material.dart';

class V3CastDevicesView extends StatefulWidget {
  const V3CastDevicesView({super.key});

  @override
  State<StatefulWidget> createState() => _V3CastDevicesViewState();
}

class _V3CastDevicesViewState extends State<V3CastDevicesView> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 30,
          top: 25,
          right: 30,
          bottom: 30,
          child: V3CastDeviceList(),
        ),
      ],
    );
  }
}
