import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_multicast_plugin/flutter_multicast_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RtpSenderPage(),
    );
  }
}

class RtpSenderPage extends StatefulWidget {
  const RtpSenderPage({super.key});

  @override
  State<RtpSenderPage> createState() => _RtpSenderPageState();
}

class _RtpSenderPageState extends State<RtpSenderPage> {
  bool _isStreaming = false;

  Future<void> _startRtp() async {
    final status = await Permission.microphone.request();
    print('Microphone permission status: $status');
    try {
      final String hexKey =
          'E1F97A0D3E018BE0D64FA32C06DE41390EC675AD498AFEEBB6960B3AABE6';

      Uint8List keyBytes = Uint8List.fromList([
        for (int i = 0; i < hexKey.length; i += 2)
          int.parse(hexKey.substring(i, i + 2), radix: 16),
      ]);

      final Uint8List masterKey = keyBytes.sublist(0, 16);
      final Uint8List masterSalt = keyBytes.sublist(16);
      print(
          'Master Key: ${masterKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
      print(
          'Master Salt: ${masterSalt.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');

      final success = await FlutterMulticastPlugin.startRtpStream(
        ip: '239.1.1.1',
        port: 5004,
        key: masterKey,
        salt: masterSalt,
        ssrc: 1234564002,
      );
      if (success == true) {
        await FlutterMulticastPlugin.startCapture();
        setState(() => _isStreaming = true);
      }
    } catch (e) {
      print('Failed to start RTP: $e');
    }
  }

  Future<void> _stopRtp() async {
    try {
      await FlutterMulticastPlugin.stopCapture();
      await FlutterMulticastPlugin.stopRtpStream();
      setState(() => _isStreaming = false);
    } catch (e) {
      print('Failed to stop RTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RTP Sender')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isStreaming ? _stopRtp : _startRtp,
              child: Text(_isStreaming ? 'Stop RTP' : 'Start RTP'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
