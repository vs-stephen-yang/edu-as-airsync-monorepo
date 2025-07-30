import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multicast_plugin/flutter_multicast_plugin.dart';

class RtpReceiver {
  /// 啟動 RTP 接收（呼叫原生的 NativeBridge.receiveStart）
  static Future<int?> start(int videoRoc, int audioRoc) async {
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

    try {
      final textureId = await FlutterMulticastPlugin.receiveStart(
        ip: '239.1.1.1',
        videoPort: 5004,
        audioPort: 5005,
        ssrc: 1234564002,
        key: masterKey,
        salt: masterSalt,
        videoRoc: videoRoc,
        audioRoc: audioRoc
      );
      return textureId;
    } on PlatformException catch (e) {
      print('Failed to start receiver: ${e.message}');
      return null;
    }
  }

  /// 停止 RTP 接收（呼叫 NativeBridge.nativeStop）
  static Future<void> stop() async {
    try {
      await FlutterMulticastPlugin.receiveStop();
    } on PlatformException catch (e) {
      print('Failed to stop receiver: ${e.message}');
    }
  }
}

void main() {
  runApp(const MaterialApp(home: ReceiverHome()));
}

class ReceiverHome extends StatefulWidget {
  const ReceiverHome({super.key});

  @override
  State<ReceiverHome> createState() => _ReceiverHomeState();
}

class _ReceiverHomeState extends State<ReceiverHome> {
  bool running = false;
  int? textureId;
  final TextEditingController _rocController = TextEditingController(text: '0');
  final TextEditingController _audioRocController = TextEditingController(text: '0');

  void _toggleReceiver() async {
    if (running) {
      await RtpReceiver.stop();
      setState(() {
        running = false;
        textureId = null;
      });
    } else {
      // 取得 ROC 值
      final rocText = _rocController.text.trim();
      if (rocText.isEmpty) {
        _showErrorDialog('請輸入 video ROC 值');
        return;
      }
      final audioRocText = _audioRocController.text.trim();
      if (audioRocText.isEmpty) {
        _showErrorDialog('請輸入 audio ROC 值');
        return;
      }

      int videoRoc;
      try {
        videoRoc = int.parse(rocText);
        if (videoRoc < 0) {
          _showErrorDialog('ROC 值必須為非負整數');
          return;
        }
      } catch (e) {
        _showErrorDialog('ROC 值必須為有效的整數');
        return;
      }

      int audioRoc;
      try {
        audioRoc = int.parse(audioRocText);
        if (audioRoc < 0) {
          _showErrorDialog('ROC 值必須為非負整數');
          return;
        }
      } catch (e) {
        _showErrorDialog('ROC 值必須為有效的整數');
        return;
      }

      final id = await RtpReceiver.start(videoRoc, audioRoc);
      if (id != null) {
        setState(() {
          running = true;
          textureId = id;
        });
      } else {
        _showErrorDialog('啟動接收器失敗');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('錯誤'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget videoWidget;
    if (textureId != null) {
      videoWidget = Texture(textureId: textureId!);
    } else {
      videoWidget = const Center(child: Text('此處將顯示影片'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('RTP Receiver')),
      body: Column(
        children: [
          Expanded(child: videoWidget),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ROC 輸入框
                TextField(
                  controller: _rocController,
                  enabled: !running, // 運行時禁用輸入
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // 只允許數字
                  ],
                  decoration: const InputDecoration(
                    labelText: 'video ROC 初始值',
                    hintText: '請輸入 ROC 值 (例如: 0, 5, 10)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                TextField(
                  controller: _audioRocController,
                  enabled: !running, // 運行時禁用輸入
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // 只允許數字
                  ],
                  decoration: const InputDecoration(
                    labelText: 'audio ROC 初始值',
                    hintText: '請輸入 audio ROC 值 (例如: 0, 5, 10)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 16),
                // 開始/停止按鈕
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _toggleReceiver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: running ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      running ? 'Stop Receiver' : 'Start Receiver',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
