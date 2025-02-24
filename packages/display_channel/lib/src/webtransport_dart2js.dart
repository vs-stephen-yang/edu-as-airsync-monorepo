import 'dart:typed_data';
import 'dart:html';

import 'package:js/js_util.dart';
import 'package:display_channel/src/webtransport_message_decoder.dart';
import 'package:display_channel/src/webtransport_message_encoder.dart';

class WebTransport {
  WebTransportMessageDecoder decoder = WebTransportMessageDecoder();
  final String _url;
  final List<String> _hashCertificates;
  dynamic _transport;
  dynamic _streamWriter;

  late Function() onOpen;
  late Function(String?) onClose;
  late Function(String) onMessage;
  late Function(String) onError;

  WebTransport(this._url, this._hashCertificates);

  Future<void> connect() async {
    List<List<int>> parsedData = parseHexList(_hashCertificates);

    final options =
        jsify({'serverCertificateHashes': generateJsOptions(parsedData)});

    try {
      _transport = callConstructor(
        getProperty(globalThis, 'WebTransport'),
        [_url, options],
      );

      final closedPromise = getProperty(_transport, 'closed');

      callMethod(
        closedPromise,
        'then',
        [
          allowInterop((_) {
            onClose(null);
          })
        ],
      );

      callMethod(
        closedPromise,
        'catch',
        [
          allowInterop((error) {
            onError(
                "WebTransport connection closed with error: ${error.toString()}");
            onClose(error.toString());
            return;
          })
        ],
      );

      // Wait for the connection to be ready
      await promiseToFuture(
        getProperty(_transport, 'ready'),
      );

      // Create a bidirectional stream and get the writer
      final stream = await promiseToFuture(
        callMethod(_transport, 'createBidirectionalStream', []),
      );
      _streamWriter =
          callMethod(getProperty(stream, 'writable'), 'getWriter', []);
      await promiseToFuture(
        getProperty(_streamWriter, 'ready'),
      );

      // Handle receiving messages
      final streamReader =
          callMethod(getProperty(stream, 'readable'), 'getReader', []);

      _startListeningToStream(streamReader);

      onOpen();
    } catch (e) {
      if (e is! DomException ||
          (!e.message!.contains("Opening handshake failed"))) {
        onError(e.toString());
        onClose(e.toString());
      }
    }
  }

  void _startListeningToStream(dynamic streamReader) async {
    while (true) {
      try {
        // Read the next chunk of data
        final streamData = await promiseToFuture(
          callMethod(streamReader, 'read', []),
        );

        // Check if the stream has ended
        if (getProperty(streamData, 'done') == true) {
          break;
        }

        // Decode and log the received data
        final receivedData = getProperty(streamData, 'value');

        if (receivedData is Uint8List) {
          List<String> messages = decoder.onDataReceived(
              receivedData); // Decode message with fixed length header
          for (var msg in messages) {
            onMessage(msg);
          }
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> send(String data) async {
    try {
      await promiseToFuture(
        getProperty(_streamWriter, 'ready'),
      );

      Uint8List framedMessage = WebTransportMessageEncoder.encodeMessage(data);

      await promiseToFuture(
        callMethod(
          _streamWriter,
          'write',
          [framedMessage],
        ),
      );
    } catch (e) {
      onError("Failed to send message: ${e.toString()}");
    }
  }

  Future<void> disconnect() async {
    if (_transport == null) {
      return;
    }

    var closeInfo = jsify({"closeCode": 0, "reason": "NormalClose"});

    try {
      // wait until ready
      await promiseToFuture(
        getProperty(_transport, 'ready'),
      );

      callMethod(_transport, 'close', [closeInfo]);
    } catch (e) {
      onError("Failed to close: ${e.toString()}");
    } finally {
      _transport = null;
      _streamWriter = null;
    }
  }

  List<List<int>> parseHexList(List<String> inputs) {
    return inputs
        .map((input) {
          try {
            // Remove spaces and split by commas
            final hexValues = input.replaceAll(' ', '').split(',');

            // Parse each value, ensuring explicit int type
            return hexValues.map<int>((hex) {
              if (hex.startsWith('0x')) {
                return int.parse(hex.substring(2), radix: 16);
              }
              return int.parse(hex, radix: 16);
            }).toList();
          } catch (e) {
            return null; // Mark this entry as invalid
          }
        })
        .where((list) => list != null)
        .cast<List<int>>()
        .toList(); // Filter out invalid entries
  }

  dynamic generateJsOptions(List<List<int>> parsedData) {
    final List<Map<String, dynamic>> certificateHashes = parsedData.map((data) {
      // Convert parsed data (List<int>) into a Uint8Array for JS interop
      final hashValue =
          callConstructor(getProperty(globalThis, 'Uint8Array'), [data]);

      return {
        'algorithm': 'sha-256',
        'value': hashValue, // Convert to JS-compatible Uint8Array
      };
    }).toList();

    return certificateHashes;
  }
}

