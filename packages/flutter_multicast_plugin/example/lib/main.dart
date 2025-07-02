import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_multicast_plugin/flutter_multicast_plugin.dart';
import 'package:flutter_multicast_plugin/stream_roc_data.dart';
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
  StreamRocData? _rocData;
  String _rocStatus = 'No ROC data available';
  bool _isLoadingRoc = false;

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
        videoPort: 5004,
        audioPort: 5005,
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

  Future<void> _getStreamRoc() async {
    if (!_isStreaming) {
      setState(() {
        _rocStatus = 'Please start streaming first';
      });
      return;
    }

    setState(() {
      _isLoadingRoc = true;
      _rocStatus = 'Loading ROC data...';
    });

    try {
      final result = await FlutterMulticastPlugin.getStreamRoc();

      if (result != null) {
        setState(() {
          _rocData = result; // 直接使用 StreamRocData 對象
          _rocStatus = 'ROC data retrieved successfully';
          _isLoadingRoc = false;
        });
        print('ROC Data - Video: ${result.videoRoc}, Audio: ${result.audioRoc}');
      } else {
        setState(() {
          _rocStatus = 'Failed to get ROC data - null result';
          _isLoadingRoc = false;
        });
      }
    } catch (e) {
      setState(() {
        _rocStatus = 'Error getting ROC data: $e';
        _isLoadingRoc = false;
      });
      print('Error getting ROC: $e');
    }
  }
  Widget _buildRocDisplay() {
    if (_rocData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ROC Status:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _rocStatus,
                style: TextStyle(
                  fontSize: 14,
                  color: _rocStatus.contains('Error') ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stream ROC Data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRocItem('Video ROC', _rocData!.videoRoc, Icons.videocam),
            _buildRocItem('Audio ROC', _rocData!.audioRoc, Icons.audiotrack),
            const SizedBox(height: 8),
            Text(
              'Status: $_rocStatus',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRocItem(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RTP Sender')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // RTP 控制按鈕
            ElevatedButton(
              onPressed: _isStreaming ? _stopRtp : _startRtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isStreaming ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
              child: Text(
                _isStreaming ? 'Stop RTP' : 'Start RTP',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // ROC 按鈕
            ElevatedButton.icon(
              onPressed: _isLoadingRoc ? null : _getStreamRoc,
              icon: _isLoadingRoc
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.info),
              label: Text(_isLoadingRoc ? 'Loading...' : 'Get Stream ROC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 45),
              ),
            ),

            const SizedBox(height: 20),

            // ROC 顯示區域
            Expanded(
              child: SingleChildScrollView(
                child: _buildRocDisplay(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
