import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:display_channel/src/webtransport_message_encoder.dart';
import 'package:display_channel/src/webtransport_message_decoder.dart'; // Adjust the import path accordingly

void main() {
  group('WebTransportMessageDecoder', () {
    late WebTransportMessageDecoder decoder;

    setUp(() {
      decoder = WebTransportMessageDecoder();
    });

    Uint8List encodeMessage(String message) {
      List<int> messageBytes = utf8.encode(message);
      int length = messageBytes.length;
      ByteData lengthData = ByteData(4)..setUint32(0, length, Endian.big);
      return Uint8List.fromList(lengthData.buffer.asUint8List() + messageBytes);
    }

    test('should decode a single complete message', () {
      String message = "Hello, World!";
      Uint8List encodedMessage = encodeMessage(message);

      List<String> result = decoder.onDataReceived(encodedMessage);

      expect(result, contains(message));
    });

    test('should decode multiple messages in a single chunk', () {
      String message1 = "Hello";
      String message2 = "World";
      Uint8List encodedMessage1 = encodeMessage(message1);
      Uint8List encodedMessage2 = encodeMessage(message2);

      List<String> result = decoder.onDataReceived(
          Uint8List.fromList([...encodedMessage1, ...encodedMessage2]));

      expect(result, containsAll([message1, message2]));
    });

    test('should handle message arriving in chunks', () {
      String message = "Chunked Message";
      Uint8List encodedMessage = encodeMessage(message);

      decoder.onDataReceived(encodedMessage.sublist(0, 3)); // Partial header
      decoder.onDataReceived(encodedMessage.sublist(3, 7)); // Rest of header + partial data
      List<String> result = decoder.onDataReceived(encodedMessage.sublist(7)); // Rest of data

      expect(result, contains(message));
    });

    test('should not decode incomplete message', () {
      String message = "Incomplete";
      Uint8List encodedMessage = encodeMessage(message);

      decoder.onDataReceived(encodedMessage.sublist(0, encodedMessage.length - 2)); // Send all but last two bytes

      expect(decoder.messages, isEmpty);
    });
  });

  group('WebTransportMessageEncoder', () {
    test('should encode message with correct length prefix', () {
      String message = "Test Message";
      Uint8List encodedMessage = WebTransportMessageEncoder.encodeMessage(message);

      // Extract the length prefix
      ByteData lengthData = ByteData.sublistView(encodedMessage.sublist(0, 4));
      int messageLength = lengthData.getUint32(0, Endian.big);

      // Extract the encoded message
      Uint8List messageBytes = Uint8List.fromList(encodedMessage.sublist(4));
      String decodedMessage = utf8.decode(messageBytes);

      expect(messageLength, equals(message.length));
      expect(decodedMessage, equals(message));
    });

    test('should encode and decode correctly', () {
      String message = "Round-trip Test";
      Uint8List encodedMessage = WebTransportMessageEncoder.encodeMessage(message);
      WebTransportMessageDecoder decoder = WebTransportMessageDecoder();

      List<String> result = decoder.onDataReceived(encodedMessage);
      expect(result, contains(message));
    });
  });
}
