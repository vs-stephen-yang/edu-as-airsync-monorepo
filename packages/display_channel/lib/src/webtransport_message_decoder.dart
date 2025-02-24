import 'dart:convert';
import 'dart:typed_data';

class WebTransportMessageDecoder {
  List<int> _buffer = []; // Buffer to store partial messages
  List<String> messages = [];

  List<String> onDataReceived(Uint8List newData) {
    _buffer.addAll(newData); // Append new data

    while (_buffer.length >= 4) {
      // Ensure at least 4 bytes for length
      // Extract 4-byte length prefix
      ByteData lengthData =
      ByteData.sublistView(Uint8List.fromList(_buffer.sublist(0, 4)));
      int messageLength = lengthData.getUint32(0, Endian.big);

      // Check if full message is available
      if (_buffer.length >= 4 + messageLength) {
        // Extract full message bytes
        Uint8List messageBytes =
        Uint8List.fromList(_buffer.sublist(4, 4 + messageLength));

        // Decode UTF-8 message
        String message = utf8.decode(messageBytes);

        // Store the decoded message
        messages.add(message);

        // Remove processed message from buffer
        _buffer = _buffer.sublist(4 + messageLength);
      } else {
        break; // Wait for more data
      }
    }

    return messages;
  }
}
