import 'dart:io';

import 'package:display_channel/display_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';

enum HttpRequestError {
  httpError, // HTTP status codes 4xx and 5xx: Client-side and Server-side errors
  invalidResponse, // Errors related to incorrect or malformed response format
  networkError, // Errors related to network issues (e.g., no connectivity)
  unknownError, // Any unhandled or unexpected errors
}

class HttpRequestException implements Exception {
  final HttpRequestError error;

  int? statusCode;
  String? message;
  String? responseBody;

  HttpRequestException(
    this.error,
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return 'HttpRequestException: Error: $error, $message, StatusCode: $statusCode, Body: $responseBody';
  }
}

enum HttpMethod { get, post, put, delete }

final _failedRequestStatusCodes = [
  SentryStatusCode.range(400, 499),
  SentryStatusCode.range(500, 599),
];

class HttpRequest<T> {
  final String _baseApiUrl;
  late ApiRequest _request;
  final _timeout = const Duration(seconds: 5);

  late ISentrySpan _transaction;
  late SentryHttpClient _client;

  HttpRequest(
    this._baseApiUrl, {
    required String path,
    Map<String, String>? queryParameters,
  }) {
    _request = buildApiRequest(
      _baseApiUrl,
      path,
      queryParameters: queryParameters,
      time: DateTime.now(),
      signatureLocation: SignatureLocation.header,
    );
  }

  Future<http.Response> _sendHttpRequest(HttpMethod method) async {
    late http.Response response;

    switch (method) {
      case HttpMethod.get:
        response = await _client
            .get(_request.url, headers: _request.headers)
            .timeout(_timeout);
      case HttpMethod.post:
        response = await _client
            .post(_request.url, headers: _request.headers, body: _request.body)
            .timeout(_timeout);
      case HttpMethod.put:
        response = await _client
            .put(_request.url, headers: _request.headers, body: _request.body)
            .timeout(_timeout);
      case HttpMethod.delete:
        response = await _client
            .delete(_request.url, headers: _request.headers)
            .timeout(_timeout);
    }

    return response;
  }

  bool isSuccessfulResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Future<T> sendRequest(
    String transactionName,
    HttpMethod method,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    _transaction = Sentry.startTransaction(
      transactionName,
      'http.request',
      bindToScope: true,
    );

    _client = SentryHttpClient(
      failedRequestStatusCodes: _failedRequestStatusCodes,
    );

    late http.Response response;

    try {
      // Send the request
      response = await _sendHttpRequest(method);
    } catch (e) {
      throw mapExceptionToHttpRequestException(e);
    } finally {
      await _transaction.finish(status: const SpanStatus.ok());

      _client.close();
    }

    if (!isSuccessfulResponse(response.statusCode)) {
      throw HttpRequestException(
        HttpRequestError.httpError,
        response.reasonPhrase,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    // Parse the response
    try {
      if (response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        return fromJson(json);
      } else {
        return fromJson({});
      }
    } catch (e, stackTrace) {
      // Invalid response
      await Sentry.captureException(e, stackTrace: stackTrace);

      throw HttpRequestException(
          HttpRequestError.invalidResponse, e.toString());
    }
  }

  HttpRequestException mapExceptionToHttpRequestException(e) {
    late HttpRequestError error;

    if (e is http.ClientException ||
        e is SocketException ||
        e is TimeoutException) {
      error = HttpRequestError.networkError;
    } else {
      error = HttpRequestError.unknownError;
    }

    return HttpRequestException(error, e.toString());
  }
}
