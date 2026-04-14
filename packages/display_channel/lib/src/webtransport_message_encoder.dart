import 'dart:convert';
import 'dart:typed_data';

class WebTransportMessageEncoder {
  static Uint8List encodeMessage(String message) {
    List<int> messageBytes = utf8.encode(message);
    int length = messageBytes.length;
    ByteData lengthData = ByteData(4)..setUint32(0, length, Endian.big);
    return Uint8List.fromList(lengthData.buffer.asUint8List() + messageBytes);
  }
}
