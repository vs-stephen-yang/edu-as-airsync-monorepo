import 'package:display_channel/display_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

    try {
      switch (method) {
        case HttpMethod.get:
          response = await http
              .get(_request.url, headers: _request.headers)
              .timeout(_timeout);
          break;
        case HttpMethod.post:
          response = await http
              .post(_request.url,
                  headers: _request.headers, body: _request.body)
              .timeout(_timeout);
          break;
        case HttpMethod.put:
          response = await http
              .put(_request.url, headers: _request.headers, body: _request.body)
              .timeout(_timeout);
          break;
        case HttpMethod.delete:
          response = await http
              .delete(_request.url, headers: _request.headers)
              .timeout(_timeout);
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          Map<String, dynamic> json = jsonDecode(response.body);
          return fromJson(json);
        } else {
          return fromJson({});
        }
      } else {
        throw HttpRequestException(
          statusCode: response.statusCode,
          message: response.reasonPhrase,
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw HttpRequestException(message: 'HTTP client error: ${e.message}');
      } else if (e is FormatException) {
        throw HttpRequestException(
            message: 'Invalid response format: ${e.message}');
      } else if (e is TimeoutException) {
        throw HttpRequestException(message: 'Request timed out');
      } else {
        throw HttpRequestException(message: e.toString());
      }
    }
  }
}
