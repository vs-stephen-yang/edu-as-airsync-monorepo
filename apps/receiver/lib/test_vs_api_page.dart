import 'package:flutter/material.dart';

import 'vsapi/vs_api.dart';

class TestVSApiPage extends StatefulWidget {
  const TestVSApiPage({super.key});

  @override
  State<TestVSApiPage> createState() => _TestVSApiPageState();
}

class _TestVSApiPageState extends State<TestVSApiPage> {
  String _serialNumber = 'Unknown';
  String _getCurrentMacAddress = 'Unknown';

  Future<void> _getDeviceInfo() async {
    try {
      final serialNumber = await VSApi().getSerialNumber();
      final getCurrentMacAddress = await VSApi().getCurrentMacAddress();

      setState(() {
        _serialNumber = serialNumber ?? 'Unknown';
        _getCurrentMacAddress = getCurrentMacAddress ?? 'Unknown';
      });
    } catch (e) {
      setState(() {
        _serialNumber = 'Error: $e';
        _getCurrentMacAddress = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VS API Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Serial Number: $_serialNumber'),
            const SizedBox(height: 20),
            Text('Current MAC Address: $_getCurrentMacAddress'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _getDeviceInfo,
              child: const Text('Get Device Info'),
            ),
          ],
        ),
      ),
    );
  }
}
