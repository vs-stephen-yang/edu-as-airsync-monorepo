import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> startWebRtcTracingCapture() async {
  final directory = await getApplicationDocumentsDirectory();

  final tracingFilename = path.join(directory.path,'webrtc-trace.txt');

  await WebRTC.invokeMethod(
    'startInternalTracingCapture',
    {
      'tracingFilename': tracingFilename,
    },
  );
}

Future<void> stopWebRtcTracingCapture() async {
  await WebRTC.invokeMethod('stopInternalTracingCapture');
}
