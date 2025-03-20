import 'dart:async';
import 'package:display_flutter/utility/log.dart';
import 'package:http/http.dart';
import 'package:async/async.dart';
import 'package:clock/clock.dart';

/// Options to configure the behavior of [CachingHttpClient].
class CachingHttpClientOptions {
  /// Minimum delay before the next retry attempt.
  final Duration minRetryDelay;

  /// Initial delay used for exponential backoff.
  final Duration initialRetryDelay;

  /// Maximum delay allowed for exponential backoff.
  final Duration maxRetryDelay;

  /// Maximum age for a cached request to be retried.
  final Duration maxRequestAge;

  /// Maximum number of requests to cache.
  final int maxQueueLength;

  const CachingHttpClientOptions({
    this.minRetryDelay = const Duration(milliseconds: 100),
    this.initialRetryDelay = const Duration(seconds: 5),
    this.maxRetryDelay = const Duration(hours: 1),
    this.maxRequestAge = const Duration(hours: 12),
    this.maxQueueLength = 60,
  });
}

/// Represents a request that is cached for later retry.
class CachedHttpRequest {
  final BaseRequest originalRequest;
  final List<int> bodyBytes;
  final DateTime createdAt;

  CachedHttpRequest({
    required this.originalRequest,
    required this.bodyBytes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? clock.now();
}

/// A client that caches failed HTTP requests and retries them with exponential backoff.
class CachingHttpClient extends BaseClient {
  final Client _innerClient;
  final Duration requestTimeout;
  final CachingHttpClientOptions options;

  final List<CachedHttpRequest> _requestQueue = [];

  Duration _currentRetryDelay;
  Timer? _retryTimer;

  CachingHttpClient({
    required Client innerClient,
    required this.requestTimeout,
    this.options = const CachingHttpClientOptions(),
  })  : _innerClient = innerClient,
        _currentRetryDelay = options.initialRetryDelay;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final cached = await _createCachedRequest(request);
    _requestQueue.add(cached);

    // Remove the oldest request if the queue length exceeds the maximum.
    if (_requestQueue.length > options.maxQueueLength) {
      _requestQueue.removeAt(0);
    }

    // Drop any requests that have become too old.
    _removeOldRequests();

    _retryTimer ??= _scheduleRetry(options.minRetryDelay);
    return StreamedResponse(const Stream<List<int>>.empty(), 200);
  }

  /// Removes cached requests older than [options.maxRequestAge].
  void _removeOldRequests() {
    final now = clock.now();

    _requestQueue.removeWhere(
        (req) => now.difference(req.createdAt) > options.maxRequestAge);
  }

  Future<CachedHttpRequest> _createCachedRequest(BaseRequest request) async {
    final splitter = StreamSplitter(request.finalize());
    final bodyBytes = await splitter.split().fold<List<int>>(
      <int>[],
      (acc, chunk) {
        acc.addAll(chunk);
        return acc;
      },
    );

    return CachedHttpRequest(originalRequest: request, bodyBytes: bodyBytes);
  }

  StreamedRequest _rebuildRequest(CachedHttpRequest cached) {
    final original = cached.originalRequest;
    final request = StreamedRequest(original.method, original.url)
      ..contentLength = original.contentLength
      ..followRedirects = original.followRedirects
      ..persistentConnection = original.persistentConnection
      ..maxRedirects = original.maxRedirects
      ..headers.addAll(original.headers);

    request.sink.add(cached.bodyBytes);
    request.sink.close();
    return request;
  }

  Timer _scheduleRetry(Duration delay) => Timer(delay, () async {
        _retryTimer = null;
        await _flushNextRequest();
      });

  Future<void> _flushNextRequest() async {
    // Clean up any outdated requests.
    _removeOldRequests();
    if (_requestQueue.isEmpty) return;

    final cached = _requestQueue.removeAt(0);
    final request = _rebuildRequest(cached);

    try {
      final response = await _innerClient.send(request).timeout(requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        log.warning('Telemetry submission failed: ${response.statusCode}');
      }
      // Reset retry delay after a successful send.
      _currentRetryDelay = options.initialRetryDelay;
      _retryTimer = _scheduleRetry(options.minRetryDelay);
    } catch (_) {
      // If sending fails, reinsert the request at the beginning.
      _requestQueue.insert(0, cached);
      _retryTimer ??= _scheduleRetry(_currentRetryDelay);

      _currentRetryDelay = _currentRetryDelay * 2;
      if (_currentRetryDelay > options.maxRetryDelay) {
        _currentRetryDelay = options.maxRetryDelay;
      }
    }
  }

  /// Immediately retries all pending requests (resets backoff).
  void flush() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _currentRetryDelay = options.initialRetryDelay;
    _retryTimer = _scheduleRetry(options.minRetryDelay);
  }
}
