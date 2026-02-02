import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_cast_flutter/utilities/app_amplify_firehose.dart';

// ============================================================================
// Test Utilities
// ============================================================================

/// Creates a mock HTTP response for testing.
FirehoseHttpResponse createMockResponse({
  required int statusCode,
  Map<String, dynamic>? jsonBody,
  String? textBody,
}) {
  final body = jsonBody != null ? jsonEncode(jsonBody) : (textBody ?? '');
  return FirehoseHttpResponse(statusCode: statusCode, body: body);
}

/// A predictable random for testing jitter behavior.
class FakeRandom implements Random {
  FakeRandom([this.value = 0.5]);
  final double value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (max * value).toInt();
}

/// Fake request signer for testing.
class FakeFirehoseRequestSigner implements FirehoseRequestSigner {
  @override
  Future<AWSBaseHttpRequest> sign(
    AWSHttpRequest request, {
    required String region,
  }) async {
    return request;
  }
}

/// Fake HTTP client for testing.
class FakeFirehoseHttpClient implements FirehoseHttpClient {
  FakeFirehoseHttpClient({this.responseBuilder});

  FirehoseHttpResponse Function(AWSBaseHttpRequest)? responseBuilder;
  final List<AWSBaseHttpRequest> sentRequests = [];

  @override
  Future<FirehoseHttpResponse> send(AWSBaseHttpRequest request) async {
    sentRequests.add(request);
    if (responseBuilder != null) {
      return responseBuilder!(request);
    }
    return createMockResponse(
      statusCode: 200,
      jsonBody: {'FailedPutCount': 0, 'RequestResponses': []},
    );
  }
}

/// Fake signer that throws exceptions for testing error handling.
class _ThrowingFirehoseRequestSigner implements FirehoseRequestSigner {
  @override
  Future<AWSBaseHttpRequest> sign(
    AWSHttpRequest request, {
    required String region,
  }) async {
    throw Exception('Signing failed');
  }
}

/// Fake connectivity monitor for testing.
class FakeConnectivityMonitor implements ConnectivityMonitor {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isConnected = true;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isConnected async => _isConnected;

  void setConnected(bool connected) {
    _isConnected = connected;
    _controller.add(connected);
  }

  void dispose() {
    _controller.close();
  }
}

/// Creates a test FirehoseClient with fake dependencies.
FirehoseClient createTestClient({
  FakeFirehoseHttpClient? httpClient,
  FakeFirehoseRequestSigner? signer,
  FakeConnectivityMonitor? connectivityMonitor,
  FirehoseConfig config = const FirehoseConfig(),
  Random? random,
  String region = 'us-east-1',
  String streamName = 'test-stream',
}) {
  return FirehoseClient(
    region: region,
    streamName: streamName,
    httpClient: httpClient ?? FakeFirehoseHttpClient(),
    signer: signer ?? FakeFirehoseRequestSigner(),
    config: config,
    connectivityMonitor: connectivityMonitor,
    random: random,
  );
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('QueuedRecord', () {
    test('should store data and creation time', () {
      final data = Uint8List.fromList(utf8.encode('test message'));
      final createdAt = DateTime.now();

      final record = QueuedRecord(data: data, createdAt: createdAt);

      expect(record.data, equals(data));
      expect(record.createdAt, equals(createdAt));
      expect(record.retryCount, equals(0));
    });

    test('should calculate size in bytes correctly', () {
      final message = 'test message with some content';
      final data = Uint8List.fromList(utf8.encode(message));

      final record = QueuedRecord(data: data, createdAt: DateTime.now());

      expect(record.sizeBytes, equals(data.length));
    });

    test('should increment retry count', () {
      final record = QueuedRecord(
        data: Uint8List.fromList([1, 2, 3]),
        createdAt: DateTime.now(),
        retryCount: 0,
      );

      final retriedRecord = record.withIncrementedRetry();

      expect(retriedRecord.retryCount, equals(1));
      expect(retriedRecord.data, equals(record.data));
      expect(retriedRecord.createdAt, equals(record.createdAt));
    });

    test('should preserve data when incrementing retry', () {
      final originalData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final originalTime = DateTime(2024, 1, 1, 12, 0);

      final record = QueuedRecord(
        data: originalData,
        createdAt: originalTime,
        retryCount: 2,
      );

      final retriedRecord = record.withIncrementedRetry();

      expect(retriedRecord.retryCount, equals(3));
      expect(retriedRecord.data, same(originalData));
      expect(retriedRecord.createdAt, equals(originalTime));
    });
  });

  group('RetryState', () {
    test('should calculate exponential backoff', () {
      final retryState = RetryState(random: FakeRandom(1.0));

      // First retry: 1s * 2 = 2s, jitter=1.0 => 2s
      final delay1 = retryState.calculateNextDelay(isThrottling: false);
      expect(delay1.inMilliseconds, equals(2000));
      expect(retryState.currentDelay.inMilliseconds, equals(2000));

      // Second retry: 2s * 2 = 4s
      final delay2 = retryState.calculateNextDelay(isThrottling: false);
      expect(delay2.inMilliseconds, equals(4000));

      // Third retry: 4s * 2 = 8s
      final delay3 = retryState.calculateNextDelay(isThrottling: false);
      expect(delay3.inMilliseconds, equals(8000));
    });

    test('should cap backoff at max delay', () {
      final retryState = RetryState(
        initialDelay: const Duration(seconds: 15),
        maxDelay: const Duration(seconds: 20),
        random: FakeRandom(1.0),
      );

      // 15s * 2 = 30s, but capped at 20s
      retryState.calculateNextDelay(isThrottling: false);
      expect(retryState.currentDelay.inSeconds, equals(20));

      // Further calls should stay at 20s
      retryState.calculateNextDelay(isThrottling: false);
      expect(retryState.currentDelay.inSeconds, equals(20));
    });

    test('should apply jitter to prevent retry storms', () {
      final retryState = RetryState(random: FakeRandom(0.5));

      final delay = retryState.calculateNextDelay(isThrottling: false);

      // 2000ms * 0.5 = 1000ms
      expect(delay.inMilliseconds, equals(1000));
    });

    test('should reset backoff after successful send', () {
      final retryState = RetryState();
      retryState.consecutiveFailures = 5;
      retryState.currentDelay = const Duration(seconds: 16);

      retryState.reset();

      expect(retryState.consecutiveFailures, equals(0));
      expect(retryState.currentDelay.inSeconds, equals(1));
    });

    test('should track consecutive failures', () {
      final retryState = RetryState();

      expect(retryState.consecutiveFailures, equals(0));

      retryState.consecutiveFailures++;
      expect(retryState.consecutiveFailures, equals(1));

      retryState.consecutiveFailures++;
      expect(retryState.consecutiveFailures, equals(2));

      retryState.reset();
      expect(retryState.consecutiveFailures, equals(0));
    });

    test('should track paused state', () {
      final retryState = RetryState();

      expect(retryState.isPaused, isFalse);

      retryState.isPaused = true;
      expect(retryState.isPaused, isTrue);

      retryState.isPaused = false;
      expect(retryState.isPaused, isFalse);
    });
  });

  group('FirehoseMetrics', () {
    test('should track all metrics', () {
      final metrics = FirehoseMetrics();

      expect(metrics.recordsEnqueued, equals(0));
      expect(metrics.recordsSent, equals(0));
      expect(metrics.recordsDropped, equals(0));
      expect(metrics.batchesSent, equals(0));
      expect(metrics.partialFailures, equals(0));

      metrics.recordsEnqueued = 100;
      metrics.recordsSent = 80;
      metrics.recordsDropped = 5;
      metrics.batchesSent = 10;
      metrics.partialFailures = 2;

      expect(metrics.recordsEnqueued, equals(100));
      expect(metrics.recordsSent, equals(80));
      expect(metrics.recordsDropped, equals(5));
      expect(metrics.batchesSent, equals(10));
      expect(metrics.partialFailures, equals(2));
    });

    test('should track timestamps', () {
      final metrics = FirehoseMetrics();

      expect(metrics.lastSuccessTime, isNull);
      expect(metrics.lastFailureTime, isNull);

      final now = DateTime.now();
      metrics.lastSuccessTime = now;
      metrics.lastFailureTime = now;

      expect(metrics.lastSuccessTime, equals(now));
      expect(metrics.lastFailureTime, equals(now));
    });

    test('should format log correctly', () {
      final metrics = FirehoseMetrics();
      metrics.recordsSent = 100;
      metrics.recordsDropped = 5;
      metrics.batchesSent = 10;
      metrics.partialFailures = 2;

      final logMessage = metrics.formatLog(25);

      expect(logMessage, contains('Queue: 25'));
      expect(logMessage, contains('Sent: 100'));
      expect(logMessage, contains('Dropped: 5'));
      expect(logMessage, contains('Batches: 10'));
      expect(logMessage, contains('Partial failures: 2'));
    });

    test('should reset all metrics', () {
      final metrics = FirehoseMetrics();
      metrics.recordsEnqueued = 100;
      metrics.recordsSent = 80;
      metrics.recordsDropped = 5;
      metrics.batchesSent = 10;
      metrics.partialFailures = 2;
      metrics.lastSuccessTime = DateTime.now();
      metrics.lastFailureTime = DateTime.now();

      metrics.reset();

      expect(metrics.recordsEnqueued, equals(0));
      expect(metrics.recordsSent, equals(0));
      expect(metrics.recordsDropped, equals(0));
      expect(metrics.batchesSent, equals(0));
      expect(metrics.partialFailures, equals(0));
      expect(metrics.lastSuccessTime, isNull);
      expect(metrics.lastFailureTime, isNull);
    });
  });

  group('FirehoseConfig', () {
    test('should have sensible defaults', () {
      const config = FirehoseConfig();

      expect(config.maxBatchRecords, equals(100));
      expect(config.maxBatchBytes, equals(2 * 1024 * 1024));
      expect(config.batchWindow, equals(const Duration(seconds: 60)));
      expect(config.maxQueueSize, equals(500));
      expect(config.maxRecordAge, equals(const Duration(hours: 1)));
      expect(config.maxRetries, equals(3));
      expect(config.metricsLogInterval, equals(const Duration(minutes: 5)));
      expect(config.initialRetryDelay, equals(const Duration(seconds: 1)));
      expect(config.maxRetryDelay, equals(const Duration(seconds: 20)));
    });

    test('should allow custom configuration', () {
      const config = FirehoseConfig(
        maxBatchRecords: 50,
        maxBatchBytes: 1024 * 1024,
        batchWindow: Duration(seconds: 30),
        maxQueueSize: 100,
        maxRecordAge: Duration(minutes: 30),
        maxRetries: 5,
        metricsLogInterval: Duration(minutes: 10),
        initialRetryDelay: Duration(seconds: 2),
        maxRetryDelay: Duration(seconds: 30),
      );

      expect(config.maxBatchRecords, equals(50));
      expect(config.maxBatchBytes, equals(1024 * 1024));
      expect(config.batchWindow, equals(const Duration(seconds: 30)));
      expect(config.maxQueueSize, equals(100));
      expect(config.maxRecordAge, equals(const Duration(minutes: 30)));
      expect(config.maxRetries, equals(5));
      expect(config.metricsLogInterval, equals(const Duration(minutes: 10)));
      expect(config.initialRetryDelay, equals(const Duration(seconds: 2)));
      expect(config.maxRetryDelay, equals(const Duration(seconds: 30)));
    });
  });

  group('FirehoseRecord', () {
    test('should create text record with newline', () {
      final record = FirehoseRecord.text('Hello World');

      expect(utf8.decode(record.data), equals('Hello World\n'));
    });

    test('should create JSON record with newline', () {
      final record = FirehoseRecord.json({'key': 'value', 'count': 42});
      final decoded = utf8.decode(record.data);

      expect(decoded, endsWith('\n'));
      expect(jsonDecode(decoded.trim()), equals({'key': 'value', 'count': 42}));
    });

    test('should create record from bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final record = FirehoseRecord.fromBytes(bytes);

      expect(record.data, equals(bytes));
    });
  });

  group('FirehoseClient - Enqueue', () {
    test('should enqueue records and track metrics', () {
      final client = createTestClient();

      client.enqueue(FirehoseRecord.text('test1'));
      client.enqueue(FirehoseRecord.text('test2'));
      client.enqueue(FirehoseRecord.text('test3'));

      expect(client.queueDepth, equals(3));
      expect(client.metrics.recordsEnqueued, equals(3));

      client.dispose();
    });

    test('should enqueue multiple records at once', () {
      final client = createTestClient();

      client.enqueueAll([
        FirehoseRecord.text('test1'),
        FirehoseRecord.text('test2'),
        FirehoseRecord.text('test3'),
      ]);

      expect(client.queueDepth, equals(3));
      expect(client.metrics.recordsEnqueued, equals(3));

      client.dispose();
    });

    test('should evict oldest records when queue exceeds max size', () {
      final client = createTestClient(
        config: const FirehoseConfig(maxQueueSize: 5),
      );

      for (var i = 0; i < 8; i++) {
        client.enqueue(FirehoseRecord.text('record $i'));
      }

      expect(client.queueDepth, equals(5));
      expect(client.metrics.recordsDropped, equals(3));

      // Verify FIFO order - oldest records (0, 1, 2) should be evicted
      final firstRecord = utf8.decode(client.pendingRecords.first.data);
      expect(firstRecord, contains('record 3'));

      client.dispose();
    });

    test('should remove expired records when enqueuing', () {
      final client = createTestClient(
        config: const FirehoseConfig(maxRecordAge: Duration(minutes: 30)),
      );

      // Manually add an old record
      client.pendingRecords.add(QueuedRecord(
        data: Uint8List.fromList(utf8.encode('old record')),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ));

      // Enqueue a new record - this should trigger expiration check
      client.enqueue(FirehoseRecord.text('new record'));

      // Old record should be removed
      expect(client.queueDepth, equals(1));
      expect(client.metrics.recordsDropped, equals(1));

      client.dispose();
    });
  });

  group('FirehoseClient - Batch Extraction', () {
    test('should respect record count limit when extracting batch', () {
      final client = createTestClient(
        config: const FirehoseConfig(maxBatchRecords: 10),
      );

      for (var i = 0; i < 15; i++) {
        client.enqueue(FirehoseRecord.text('record $i'));
      }

      expect(client.queueDepth, equals(15));

      client.dispose();
    });

    test('should respect size limit when extracting batch', () {
      final client = createTestClient(
        config: const FirehoseConfig(maxBatchBytes: 1024),
      );

      // Create records of ~200 bytes each
      for (var i = 0; i < 10; i++) {
        final largeMessage = 'x' * 200;
        client.enqueue(FirehoseRecord.text(largeMessage));
      }

      expect(client.queueDepth, equals(10));

      client.dispose();
    });
  });

  group('FirehoseClient - Send Batch', () {
    test('should send batch successfully and update metrics', () async {
      final httpClient = FakeFirehoseHttpClient();
      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      expect(client.queueDepth, equals(0));
      expect(client.metrics.recordsSent, equals(1));
      expect(client.metrics.batchesSent, equals(1));
      expect(httpClient.sentRequests.length, equals(1));

      client.dispose();
    });

    test('should include correct headers in request', () async {
      final httpClient = FakeFirehoseHttpClient();
      final client = createTestClient(
        httpClient: httpClient,
        region: 'us-west-2',
        streamName: 'my-stream',
      );

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      final request = httpClient.sentRequests.first as AWSHttpRequest;
      expect(request.headers['Content-Type'], equals('application/x-amz-json-1.1'));
      expect(request.headers['X-Amz-Target'], equals('Firehose_20150804.PutRecordBatch'));
      expect(request.uri.host, equals('firehose.us-west-2.amazonaws.com'));

      client.dispose();
    });

    test('should encode records as base64 in request body', () async {
      final httpClient = FakeFirehoseHttpClient();
      final client = createTestClient(
        httpClient: httpClient,
        streamName: 'test-stream',
      );

      client.enqueue(FirehoseRecord.text('hello'));
      await client.flush();

      final request = httpClient.sentRequests.first as AWSHttpRequest;
      // Collect stream body bytes
      final bodyChunks = await request.body.toList();
      final bodyBytes = bodyChunks.expand((chunk) => chunk).toList();
      final bodyJson = jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;

      expect(bodyJson['DeliveryStreamName'], equals('test-stream'));
      expect(bodyJson['Records'], isA<List>());
      expect((bodyJson['Records'] as List).length, equals(1));

      final recordData = (bodyJson['Records'] as List).first['Data'] as String;
      final decoded = utf8.decode(base64.decode(recordData));
      expect(decoded, equals('hello\n'));

      client.dispose();
    });

    test('should handle partial failures and re-enqueue failed records', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 200,
          jsonBody: {
            'FailedPutCount': 1,
            'RequestResponses': [
              {'RecordId': 'success-1'},
              {'ErrorCode': 'ServiceUnavailableException'},
              {'RecordId': 'success-2'},
            ],
          },
        ),
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueueAll([
        FirehoseRecord.text('test1'),
        FirehoseRecord.text('test2'),
        FirehoseRecord.text('test3'),
      ]);
      await client.flush();

      // 1 record failed and should be re-enqueued with incremented retry
      expect(client.queueDepth, equals(1));
      expect(client.pendingRecords.first.retryCount, equals(1));
      expect(client.metrics.partialFailures, equals(1));
      expect(client.metrics.recordsSent, equals(2));

      client.dispose();
    });

    test('should drop records after max retries', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 200,
          jsonBody: {
            'FailedPutCount': 1,
            'RequestResponses': [
              {'ErrorCode': 'InternalFailure'},
            ],
          },
        ),
      );

      final client = createTestClient(
        httpClient: httpClient,
        config: const FirehoseConfig(maxRetries: 3),
      );

      client.enqueue(FirehoseRecord.text('test'));

      // Flush multiple times to exhaust retries
      await client.flush();
      expect(client.pendingRecords.first.retryCount, equals(1));

      await client.flush();
      expect(client.pendingRecords.first.retryCount, equals(2));

      await client.flush();
      // After 3rd retry, record should be dropped
      expect(client.queueDepth, equals(0));
      expect(client.metrics.recordsDropped, equals(1));

      client.dispose();
    });

    test('should reset retry state after successful send', () async {
      var callCount = 0;
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          callCount++;
          if (callCount == 1) {
            // First call fails
            return createMockResponse(
              statusCode: 500,
              textBody: 'Internal Server Error',
            );
          }
          // Second call succeeds
          return createMockResponse(
            statusCode: 200,
            jsonBody: {'FailedPutCount': 0, 'RequestResponses': []},
          );
        },
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // First flush fails
      expect(client.retryState.consecutiveFailures, equals(1));

      // Second flush succeeds
      await client.flush();
      expect(client.retryState.consecutiveFailures, equals(0));

      client.dispose();
    });
  });

  group('FirehoseClient - Error Handling', () {
    test('should handle non-retryable errors and drop batch', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 400,
          textBody: 'Bad Request',
        ),
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // Non-retryable error should drop the batch
      expect(client.queueDepth, equals(0));
      expect(client.metrics.recordsDropped, equals(1));

      client.dispose();
    });

    test('should handle 403 and trigger credential refresh', () async {
      var refreshCalled = false;
      final signer = FakeFirehoseRequestSigner();

      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 403,
          textBody: 'Access Denied',
        ),
      );

      final client = createTestClient(
        httpClient: httpClient,
        signer: signer,
      );

      client.onCredentialRefreshNeeded = () async {
        refreshCalled = true;
        return signer;
      };

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      expect(refreshCalled, isTrue);

      client.dispose();
    });

    test('should handle 400 ExpiredTokenException and trigger credential refresh', () async {
      var refreshCalled = false;
      final signer = FakeFirehoseRequestSigner();

      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 400,
          textBody: '{"__type":"ExpiredTokenException","message":"The security token included in the request is expired"}',
        ),
      );

      final client = createTestClient(
        httpClient: httpClient,
        signer: signer,
      );

      client.onCredentialRefreshNeeded = () async {
        refreshCalled = true;
        return signer;
      };

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      expect(refreshCalled, isTrue);

      client.dispose();
    });

    test('should retry batch immediately after credential refresh succeeds', () async {
      var callCount = 0;
      var refreshCalled = false;
      final signer = FakeFirehoseRequestSigner();

      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          callCount++;
          if (callCount == 1) {
            // First call fails with expired token
            return createMockResponse(
              statusCode: 400,
              textBody: '{"__type":"ExpiredTokenException","message":"Token expired"}',
            );
          }
          // Second call (after refresh) succeeds
          return createMockResponse(
            statusCode: 200,
            jsonBody: {'FailedPutCount': 0, 'RequestResponses': []},
          );
        },
      );

      final client = createTestClient(
        httpClient: httpClient,
        signer: signer,
      );

      client.onCredentialRefreshNeeded = () async {
        refreshCalled = true;
        return signer;
      };

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      expect(refreshCalled, isTrue);
      expect(callCount, equals(2)); // Initial call + retry after refresh
      expect(client.queueDepth, equals(0)); // Record was sent successfully
      expect(client.metrics.recordsSent, equals(1));

      client.dispose();
    });

    test('should not retry infinitely after credential refresh', () async {
      var callCount = 0;
      var refreshCount = 0;
      final signer = FakeFirehoseRequestSigner();

      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          callCount++;
          // Always return expired token error
          return createMockResponse(
            statusCode: 400,
            textBody: '{"__type":"ExpiredTokenException","message":"Token expired"}',
          );
        },
      );

      final client = createTestClient(
        httpClient: httpClient,
        signer: signer,
      );

      client.onCredentialRefreshNeeded = () async {
        refreshCount++;
        return signer;
      };

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // Should only retry once after refresh (not infinite loop)
      expect(callCount, equals(2)); // Initial + 1 retry
      expect(refreshCount, equals(1)); // Only one refresh attempt per batch send

      client.dispose();
    });

    test('should retry on retryable errors', () async {
      var callCount = 0;
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          callCount++;
          if (callCount < 3) {
            return createMockResponse(
              statusCode: 503,
              textBody: 'Service Unavailable',
            );
          }
          return createMockResponse(
            statusCode: 200,
            jsonBody: {'FailedPutCount': 0, 'RequestResponses': []},
          );
        },
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));

      // Multiple flushes to simulate retries
      await client.flush();
      await client.flush();
      await client.flush();

      expect(client.queueDepth, equals(0));
      expect(callCount, equals(3));

      client.dispose();
    });

    test('should track failure time on error', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 500,
          textBody: 'Internal Error',
        ),
      );

      final client = createTestClient(httpClient: httpClient);
      expect(client.metrics.lastFailureTime, isNull);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      expect(client.metrics.lastFailureTime, isNotNull);

      client.dispose();
    });
  });

  group('FirehoseClient - Connectivity', () {
    test('should pause when connectivity is lost', () async {
      final connectivity = FakeConnectivityMonitor();
      final client = createTestClient(connectivityMonitor: connectivity);
      client.start();

      expect(client.isPaused, isFalse);

      // Simulate going offline
      connectivity.setConnected(false);
      await Future.delayed(Duration.zero);

      expect(client.isPaused, isTrue);

      client.dispose();
      connectivity.dispose();
    });

    test('should resume when connectivity is restored', () async {
      final connectivity = FakeConnectivityMonitor();
      final client = createTestClient(connectivityMonitor: connectivity);
      client.start();

      // Go offline
      connectivity.setConnected(false);
      await Future.delayed(Duration.zero);
      expect(client.isPaused, isTrue);

      // Come back online
      connectivity.setConnected(true);
      await Future.delayed(Duration.zero);
      expect(client.isPaused, isFalse);

      client.dispose();
      connectivity.dispose();
    });

    test('should not send when paused', () async {
      final httpClient = FakeFirehoseHttpClient();
      final connectivity = FakeConnectivityMonitor();
      final client = createTestClient(
        httpClient: httpClient,
        connectivityMonitor: connectivity,
      );
      client.start();

      // Go offline
      connectivity.setConnected(false);
      await Future.delayed(Duration.zero);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // No requests should be sent while paused
      expect(httpClient.sentRequests.length, equals(0));
      expect(client.queueDepth, equals(1));

      client.dispose();
      connectivity.dispose();
    });

    test('should flush queue when connectivity is restored', () async {
      final httpClient = FakeFirehoseHttpClient();
      final connectivity = FakeConnectivityMonitor();
      final client = createTestClient(
        httpClient: httpClient,
        connectivityMonitor: connectivity,
      );
      client.start();

      // Enqueue while online
      client.enqueue(FirehoseRecord.text('test'));

      // Go offline
      connectivity.setConnected(false);
      await Future.delayed(Duration.zero);

      // Come back online - should trigger flush
      connectivity.setConnected(true);
      await Future.delayed(Duration.zero);

      // Give time for the async flush to complete
      await Future.delayed(const Duration(milliseconds: 10));

      client.dispose();
      connectivity.dispose();
    });
  });

  group('FirehoseClient - Error Classification', () {
    test('should classify 429/503 as retryable throttling errors', () {
      expect(FirehoseClient.isRetryableError(429, ''), isTrue);
      expect(FirehoseClient.isRetryableError(503, ''), isTrue);
    });

    test('should classify 500/502/504 as retryable transient errors', () {
      expect(FirehoseClient.isRetryableError(500, ''), isTrue);
      expect(FirehoseClient.isRetryableError(502, ''), isTrue);
      expect(FirehoseClient.isRetryableError(504, ''), isTrue);
    });

    test('should classify 400/403/404 as non-retryable', () {
      expect(FirehoseClient.isRetryableError(400, ''), isFalse);
      expect(FirehoseClient.isRetryableError(403, ''), isFalse);
      expect(FirehoseClient.isRetryableError(404, ''), isFalse);
    });

    test('should classify 200/201/204 as non-retryable (success)', () {
      expect(FirehoseClient.isRetryableError(200, ''), isFalse);
      expect(FirehoseClient.isRetryableError(201, ''), isFalse);
      expect(FirehoseClient.isRetryableError(204, ''), isFalse);
    });

    test('should identify ServiceUnavailableException in response body', () {
      expect(
        FirehoseClient.isRetryableError(
            400, '{"__type": "ServiceUnavailableException"}'),
        isTrue,
      );
    });

    test('should identify InternalFailure in response body', () {
      expect(
        FirehoseClient.isRetryableError(400, '{"__type": "InternalFailure"}'),
        isTrue,
      );
    });

    test('should identify throttling errors from error object', () {
      expect(
        FirehoseClient.isThrottlingError(
            Exception('Error 429: Too many requests')),
        isTrue,
      );
      expect(
        FirehoseClient.isThrottlingError(
            Exception('Error 503: Service unavailable')),
        isTrue,
      );
      expect(
        FirehoseClient.isThrottlingError(
            Exception('ServiceUnavailableException')),
        isTrue,
      );
      expect(FirehoseClient.isThrottlingError(Exception('Throttling')), isTrue);
    });

    test('should not classify regular errors as throttling', () {
      expect(
        FirehoseClient.isThrottlingError(Exception('Error 500: Internal error')),
        isFalse,
      );
      expect(
        FirehoseClient.isThrottlingError(Exception('Network timeout')),
        isFalse,
      );
      expect(
        FirehoseClient.isThrottlingError(Exception('Connection refused')),
        isFalse,
      );
    });
  });

  group('FirehoseClient - Timers', () {
    test('should flush batch after configured window', () {
      fakeAsync((async) {
        var timerFired = false;
        const batchWindow = Duration(seconds: 60);

        Timer.periodic(batchWindow, (_) {
          timerFired = true;
        });

        async.elapse(const Duration(seconds: 59));
        expect(timerFired, isFalse);

        async.elapse(const Duration(seconds: 1));
        expect(timerFired, isTrue);
      });
    });

    test('should log metrics periodically', () {
      fakeAsync((async) {
        var logCount = 0;
        const metricsLogInterval = Duration(minutes: 5);

        Timer.periodic(metricsLogInterval, (_) {
          logCount++;
        });

        async.elapse(const Duration(minutes: 15));
        expect(logCount, equals(3));
      });
    });

    test('should use configured batch window', () {
      final client = createTestClient(
        config: const FirehoseConfig(batchWindow: Duration(seconds: 30)),
      );

      expect(client.config.batchWindow, equals(const Duration(seconds: 30)));

      client.dispose();
    });
  });

  group('FirehoseClient - Disposal', () {
    test('should cancel all timers on dispose', () {
      fakeAsync((async) {
        var batchTimerActive = false;
        var metricsTimerActive = false;

        final batchTimer = Timer.periodic(
          const Duration(seconds: 60),
          (_) => batchTimerActive = true,
        );
        final metricsTimer = Timer.periodic(
          const Duration(minutes: 5),
          (_) => metricsTimerActive = true,
        );

        // Simulate dispose
        batchTimer.cancel();
        metricsTimer.cancel();

        async.elapse(const Duration(minutes: 10));

        expect(batchTimerActive, isFalse);
        expect(metricsTimerActive, isFalse);
      });
    });

    test('should cancel connectivity subscription on dispose', () async {
      final connectivity = FakeConnectivityMonitor();
      final client = createTestClient(connectivityMonitor: connectivity);
      client.start();

      client.dispose();

      // Setting connectivity after dispose should not affect client
      connectivity.setConnected(false);
      await Future.delayed(Duration.zero);

      connectivity.dispose();
    });

    test('should clear pending records reference after dispose', () {
      final client = createTestClient();

      client.enqueue(FirehoseRecord.text('test'));
      expect(client.queueDepth, equals(1));

      client.dispose();

      // pendingRecords list still exists but timers are cancelled
      expect(client.pendingRecords.length, equals(1));
    });
  });

  group('FirehoseStreamType', () {
    test('should have encoder and decoder types', () {
      expect(FirehoseStreamType.values, contains(FirehoseStreamType.encoder));
      expect(FirehoseStreamType.values, contains(FirehoseStreamType.decoder));
    });

    test('should have correct name values', () {
      expect(FirehoseStreamType.encoder.name, equals('encoder'));
      expect(FirehoseStreamType.decoder.name, equals('decoder'));
    });

    test('should have exactly 2 values', () {
      expect(FirehoseStreamType.values.length, equals(2));
    });
  });

  group('FirehoseHttpResponse', () {
    test('should store status code and body', () {
      final response = FirehoseHttpResponse(
        statusCode: 200,
        body: '{"result": "ok"}',
      );

      expect(response.statusCode, equals(200));
      expect(response.body, equals('{"result": "ok"}'));
    });

    test('should handle empty body', () {
      final response = FirehoseHttpResponse(
        statusCode: 204,
        body: '',
      );

      expect(response.statusCode, equals(204));
      expect(response.body, isEmpty);
    });

    test('should handle error response', () {
      final response = FirehoseHttpResponse(
        statusCode: 500,
        body: '{"error": "Internal Server Error"}',
      );

      expect(response.statusCode, equals(500));
      expect(response.body, contains('Internal Server Error'));
    });
  });

  group('FirehoseClient - Critical Edge Cases', () {
    test('should handle HTTP client exception (network error)', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => throw Exception('Network timeout'),
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // Record should still be in queue for retry
      expect(client.queueDepth, equals(1));
      expect(client.metrics.lastFailureTime, isNotNull);
      expect(client.retryState.consecutiveFailures, equals(1));

      client.dispose();
    });

    test('should handle malformed JSON response body', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => FirehoseHttpResponse(
          statusCode: 200,
          body: 'not valid json {{{',
        ),
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));

      // Should throw and handle the error gracefully
      await client.flush();

      // Record should still be in queue due to parse error
      expect(client.queueDepth, equals(1));
      expect(client.retryState.consecutiveFailures, equals(1));

      client.dispose();
    });

    test('should handle empty queue flush gracefully', () async {
      final httpClient = FakeFirehoseHttpClient();
      final client = createTestClient(httpClient: httpClient);

      // Flush empty queue should not throw or send requests
      await client.flush();

      expect(httpClient.sentRequests.length, equals(0));
      expect(client.metrics.batchesSent, equals(0));

      client.dispose();
    });

    test('should auto-flush when batch record count threshold reached', () async {
      final httpClient = FakeFirehoseHttpClient();
      final client = createTestClient(
        httpClient: httpClient,
        config: const FirehoseConfig(maxBatchRecords: 3),
      );

      // Add records up to threshold
      client.enqueue(FirehoseRecord.text('test1'));
      client.enqueue(FirehoseRecord.text('test2'));

      // Should not have sent yet (below threshold)
      expect(httpClient.sentRequests.length, equals(0));

      // This should trigger auto-flush (reaches threshold)
      client.enqueue(FirehoseRecord.text('test3'));

      // Wait for async flush to complete
      await Future.delayed(const Duration(milliseconds: 10));

      expect(httpClient.sentRequests.length, equals(1));

      client.dispose();
    });

    test('should auto-flush when batch bytes threshold reached', () async {
      final httpClient = FakeFirehoseHttpClient();
      final client = createTestClient(
        httpClient: httpClient,
        config: const FirehoseConfig(maxBatchBytes: 50),
      );

      // Add a record that alone doesn't exceed threshold
      client.enqueue(FirehoseRecord.text('x' * 20)); // ~21 bytes
      expect(httpClient.sentRequests.length, equals(0)); // Not yet

      // Add another record that pushes total over threshold
      client.enqueue(FirehoseRecord.text('x' * 40)); // ~41 bytes, total ~62 bytes > 50

      // Wait for async flush to complete
      await Future.delayed(const Duration(milliseconds: 10));

      expect(httpClient.sentRequests.length, equals(1));

      client.dispose();
    });

    test('should handle all records failing in partial failure response', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 200,
          jsonBody: {
            'FailedPutCount': 3,
            'RequestResponses': [
              {'ErrorCode': 'InternalFailure'},
              {'ErrorCode': 'ServiceUnavailableException'},
              {'ErrorCode': 'InternalFailure'},
            ],
          },
        ),
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueueAll([
        FirehoseRecord.text('test1'),
        FirehoseRecord.text('test2'),
        FirehoseRecord.text('test3'),
      ]);
      await client.flush();

      // All records should be re-enqueued with incremented retry count
      expect(client.queueDepth, equals(3));
      expect(client.metrics.partialFailures, equals(1));
      expect(client.metrics.recordsSent, equals(0));

      // All should have retry count of 1
      for (final record in client.pendingRecords) {
        expect(record.retryCount, equals(1));
      }

      client.dispose();
    });

    test('should handle credential refresh returning null', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 403,
          textBody: 'Access Denied',
        ),
      );

      final client = createTestClient(httpClient: httpClient);

      client.onCredentialRefreshNeeded = () async {
        return null; // Simulate refresh failure
      };

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // Should have attempted the request and failed
      expect(client.retryState.consecutiveFailures, equals(1));

      client.dispose();
    });

    test('should serialize concurrent flush calls', () async {
      var callCount = 0;

      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          callCount++;
          return createMockResponse(
            statusCode: 200,
            jsonBody: {'FailedPutCount': 0, 'RequestResponses': []},
          );
        },
      );

      final client = createTestClient(
        httpClient: httpClient,
        config: const FirehoseConfig(maxBatchRecords: 10), // Larger batch to avoid auto-flush
      );

      client.enqueue(FirehoseRecord.text('test1'));
      client.enqueue(FirehoseRecord.text('test2'));
      client.enqueue(FirehoseRecord.text('test3'));

      // Start multiple flushes concurrently - they should be serialized
      final futures = [
        client.flush(),
        client.flush(),
        client.flush(),
      ];

      await Future.wait(futures);

      // Only one actual batch should be sent (all records in one batch)
      // The other flush calls should find the queue empty
      expect(callCount, equals(1));
      expect(client.queueDepth, equals(0));
      expect(client.metrics.recordsSent, equals(3));

      client.dispose();
    });

    test('should handle signer throwing exception', () async {
      final signer = _ThrowingFirehoseRequestSigner();
      final httpClient = FakeFirehoseHttpClient();

      final client = FirehoseClient(
        region: 'us-east-1',
        streamName: 'test-stream',
        httpClient: httpClient,
        signer: signer,
        config: const FirehoseConfig(),
      );

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // Should have failed and record should remain
      expect(client.queueDepth, equals(1));
      expect(client.retryState.consecutiveFailures, equals(1));
      expect(httpClient.sentRequests.length, equals(0)); // Never reached HTTP client

      client.dispose();
    });

    test('should handle partial failure with empty RequestResponses', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 200,
          jsonBody: {
            'FailedPutCount': 1,
            'RequestResponses': [], // Empty but FailedPutCount > 0
          },
        ),
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // Should treat as success since we can't identify which failed
      expect(client.queueDepth, equals(0));
      expect(client.metrics.batchesSent, equals(1));

      client.dispose();
    });

    test('should handle partial failure with null RequestResponses', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) => createMockResponse(
          statusCode: 200,
          jsonBody: {
            'FailedPutCount': 1,
            // No RequestResponses key
          },
        ),
      );

      final client = createTestClient(httpClient: httpClient);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      // Should treat as success since we can't identify which failed
      expect(client.queueDepth, equals(0));
      expect(client.metrics.batchesSent, equals(1));

      client.dispose();
    });

    test('should drop records that exceed max retries during exception handling', () async {
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          throw Exception('Persistent network error');
        },
      );

      final client = createTestClient(
        httpClient: httpClient,
        config: const FirehoseConfig(maxRetries: 2),
      );

      // Manually add a record that's already at max retries
      client.pendingRecords.add(QueuedRecord(
        data: Uint8List.fromList(utf8.encode('old record')),
        createdAt: DateTime.now(),
        retryCount: 2, // Already at max
      ));
      client.metrics.recordsEnqueued++;

      await client.flush();

      // Record should be dropped after exception since it's at max retries
      expect(client.queueDepth, equals(0));
      expect(client.metrics.recordsDropped, equals(1));

      client.dispose();
    });

    test('should track success time after successful batch', () async {
      final httpClient = FakeFirehoseHttpClient();
      final client = createTestClient(httpClient: httpClient);

      expect(client.metrics.lastSuccessTime, isNull);

      client.enqueue(FirehoseRecord.text('test'));
      await client.flush();

      expect(client.metrics.lastSuccessTime, isNotNull);
      expect(
        client.metrics.lastSuccessTime!.difference(DateTime.now()).inSeconds.abs(),
        lessThan(2),
      );

      client.dispose();
    });
  });

  group('Integration', () {
    test('should process multiple batches correctly', () async {
      var batchCount = 0;
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          batchCount++;
          return createMockResponse(
            statusCode: 200,
            jsonBody: {'FailedPutCount': 0, 'RequestResponses': []},
          );
        },
      );

      final client = createTestClient(
        httpClient: httpClient,
        config: const FirehoseConfig(maxBatchRecords: 5),
      );

      // Add 12 records (should result in 3 batches: 5, 5, 2)
      for (var i = 0; i < 12; i++) {
        client.enqueue(FirehoseRecord.text('record $i'));
      }

      await client.flush();
      await client.flush();
      await client.flush();

      expect(client.queueDepth, equals(0));
      expect(client.metrics.recordsSent, equals(12));
      expect(batchCount, equals(3));

      client.dispose();
    });

    test('should handle mixed success and failure across batches', () async {
      var callCount = 0;
      final httpClient = FakeFirehoseHttpClient(
        responseBuilder: (_) {
          callCount++;
          if (callCount == 1) {
            // First batch has 1 failure
            return createMockResponse(
              statusCode: 200,
              jsonBody: {
                'FailedPutCount': 1,
                'RequestResponses': [
                  {'RecordId': 'ok'},
                  {'ErrorCode': 'InternalFailure'},
                ],
              },
            );
          }
          // Subsequent batches succeed
          return createMockResponse(
            statusCode: 200,
            jsonBody: {'FailedPutCount': 0, 'RequestResponses': []},
          );
        },
      );

      final client = createTestClient(
        httpClient: httpClient,
        config: const FirehoseConfig(maxBatchRecords: 3), // Use 3 to avoid auto-flush on enqueue
      );

      client.enqueueAll([
        FirehoseRecord.text('test1'),
        FirehoseRecord.text('test2'),
      ]);

      await client.flush();
      expect(client.metrics.partialFailures, equals(1));
      expect(client.queueDepth, equals(1)); // 1 failed record re-enqueued

      await client.flush();
      expect(client.queueDepth, equals(0)); // Failed record now succeeds

      client.dispose();
    });
  });
}
