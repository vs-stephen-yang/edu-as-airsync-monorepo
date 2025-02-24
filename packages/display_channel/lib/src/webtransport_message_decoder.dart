import 'dart:convert';
import 'dart:typed_data';

class WebTransportMessageDecoder {
  static const int lengthPrefixSize = 4; // Number of bytes for length prefix

  List<int> _buffer = []; // Buffer to store partial messages
  List<String> messages = [];

  List<String> onDataReceived(Uint8List newData) {
    _buffer.addAll(newData); // Append new data

    while (_buffer.length >= lengthPrefixSize) {
      // Ensure at least `lengthPrefixSize` bytes for length
      // Extract `lengthPrefixSize`-byte length prefix
      ByteData lengthData =
      ByteData.sublistView(Uint8List.fromList(_buffer.sublist(0, lengthPrefixSize)));
      int messageLength = lengthData.getUint32(0, Endian.big);

      // Check if full message is available
      if (_buffer.length >= lengthPrefixSize + messageLength) {
        // Extract full message bytes
        Uint8List messageBytes =
        Uint8List.fromList(_buffer.sublist(lengthPrefixSize, lengthPrefixSize + messageLength));

        // Decode UTF-8 message
        String message = utf8.decode(messageBytes);

        // Store the decoded message
        messages.add(message);

        // Remove processed message from buffer
        _buffer = _buffer.sublist(lengthPrefixSize + messageLength);
      } else {
        break; // Wait for more data
      }
    }

    return messages;
  }
}
