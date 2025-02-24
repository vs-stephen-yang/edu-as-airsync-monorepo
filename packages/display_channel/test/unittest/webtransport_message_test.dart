import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:display_channel/src/webtransport_message_encoder.dart';
import 'package:display_channel/src/webtransport_message_decoder.dart';

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
      // Arrange
      String message = "Hello, World!";
      Uint8List encodedMessage = encodeMessage(message);

      // Act
      List<String> result = decoder.onDataReceived(encodedMessage);

      // Assert
      expect(result, contains(message));
    });

    test('should decode multiple messages in a single chunk', () {
      // Arrange
      String message1 = "Hello";
      String message2 = "World";
      Uint8List encodedMessage1 = encodeMessage(message1);
      Uint8List encodedMessage2 = encodeMessage(message2);
      Uint8List combinedMessages = Uint8List.fromList([...encodedMessage1, ...encodedMessage2]);

      // Act
      List<String> result = decoder.onDataReceived(combinedMessages);

      // Assert
      expect(result, containsAll([message1, message2]));
    });

    test('should handle message arriving in chunks', () {
      // Arrange
      String message = "Chunked Message";
      Uint8List encodedMessage = encodeMessage(message);

      // Act
      decoder.onDataReceived(encodedMessage.sublist(0, 3)); // Partial header
      decoder.onDataReceived(encodedMessage.sublist(3, 7)); // Rest of header + partial data
      List<String> result = decoder.onDataReceived(encodedMessage.sublist(7)); // Rest of data

      // Assert
      expect(result, contains(message));
    });

    test('should not decode incomplete message', () {
      // Arrange
      String message = "Incomplete";
      Uint8List encodedMessage = encodeMessage(message);
      Uint8List incompleteMessage = encodedMessage.sublist(0, encodedMessage.length - 2); // Truncate last 2 bytes

      // Act
      decoder.onDataReceived(incompleteMessage);

      // Assert
      expect(decoder.messages, isEmpty);
    });
  });

  group('WebTransportMessageEncoder', () {
    test('should encode message with correct length prefix', () {
      // Arrange
      String message = "Test Message";

      // Act
      Uint8List encodedMessage = WebTransportMessageEncoder.encodeMessage(message);

      // Extract the length prefix
      ByteData lengthData = ByteData.sublistView(encodedMessage.sublist(0, 4));
      int messageLength = lengthData.getUint32(0, Endian.big);

      // Extract the encoded message
      Uint8List messageBytes = Uint8List.fromList(encodedMessage.sublist(4));
      String decodedMessage = utf8.decode(messageBytes);

      // Assert
      expect(messageLength, equals(message.length));
      expect(decodedMessage, equals(message));
    });

    test('should encode and decode correctly', () {
      // Arrange
      String message = "Round-trip Test";
      WebTransportMessageDecoder decoder = WebTransportMessageDecoder();

      // Act
      Uint8List encodedMessage = WebTransportMessageEncoder.encodeMessage(message);
      List<String> result = decoder.onDataReceived(encodedMessage);

      // Assert
      expect(result, contains(message));
    });
  });
}
