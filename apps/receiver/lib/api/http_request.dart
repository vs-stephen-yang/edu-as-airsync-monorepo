import 'dart:io';

import 'package:display_channel/display_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';

class HttpRequestException implements Exception {
  int? statusCode;
  String? message;

  HttpRequestException({this.statusCode, this.message});

  @override
  String toString() {
    return 'HttpRequestException: StatusCode: $statusCode, Message: $message';
  }
}

enum HttpMethod { get, post, put, delete }

class HttpRequest<T> {
  final String _baseApiUrl;
  late final ApiRequest _request;
  final _timeout = const Duration(seconds: 5);

  HttpRequest(
    this._baseApiUrl, {
    required String path,
    Map<String, String>? queryParameters,
  }) {
    try {
      _request = buildApiRequest(
        _baseApiUrl,
        path,
        queryParameters: queryParameters,
        time: DateTime.now(),
        signatureLocation: SignatureLocation.header,
      );
    } catch (e) {
      throw HttpRequestException(
          message: 'Failed to build API request: ${e.toString()}');
    }
  }

  Future<T> sendRequest(
    HttpMethod method,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    http.Response response;

    final transaction = Sentry.startTransaction(
      'webrequest',
      'request',
      bindToScope: true,
    );

    final client = SentryHttpClient(
      failedRequestStatusCodes: [
        SentryStatusCode.range(400, 499),
        SentryStatusCode.range(500, 599),
      ],
    );

    try {
      switch (method) {
        case HttpMethod.get:
          response = await client
              .get(_request.url, headers: _request.headers)
              .timeout(_timeout);
          break;
        case HttpMethod.post:
          response = await client
              .post(_request.url,
                  headers: _request.headers, body: _request.body)
              .timeout(_timeout);
          break;
        case HttpMethod.put:
          response = await client
              .put(_request.url, headers: _request.headers, body: _request.body)
              .timeout(_timeout);
          break;
        case HttpMethod.delete:
          response = await client
              .delete(_request.url, headers: _request.headers)
              .timeout(_timeout);
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await transaction.finish(
            status: SpanStatus.fromHttpStatusCode(response.statusCode));

        if (response.body.isNotEmpty) {
          Map<String, dynamic> json = jsonDecode(response.body);
          return fromJson(json);
        } else {
          return fromJson({});
        }
      } else {
        await transaction.finish(
            status: SpanStatus.fromHttpStatusCode(response.statusCode));

        throw HttpRequestException(
          statusCode: response.statusCode,
          message: response.reasonPhrase,
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw HttpRequestException(message: 'HTTP client error: ${e.message}');
      } else if (e is FormatException) {
        // Invalid response format
        await transaction.finish(status: const SpanStatus.internalError());
        throw HttpRequestException(
            message: 'Invalid response format: ${e.message}');
      } else if (e is SocketException) {
        // Network unavailable case
        await transaction.finish(status: const SpanStatus.unavailable());
        throw HttpRequestException(message: 'Network error: ${e.message}');
      } else if (e is TimeoutException) {
        // Timeout case
        await transaction.finish(status: const SpanStatus.deadlineExceeded());
        throw HttpRequestException(message: 'Request timed out');
      } else {
        await transaction.finish(status: const SpanStatus.internalError());
        throw HttpRequestException(message: e.toString());
      }
    } finally {
      client.close();
    }
  }
}
