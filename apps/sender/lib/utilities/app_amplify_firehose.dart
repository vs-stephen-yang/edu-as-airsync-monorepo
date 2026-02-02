import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' as amplify_auth;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart' as sigv4;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter/foundation.dart';

enum FirehoseStreamType { encoder, decoder }

// ============================================================================
// Configuration
// ============================================================================

/// Configuration for the Firehose client.
class FirehoseConfig {
  const FirehoseConfig({
    this.maxBatchRecords = 100,
    this.maxBatchBytes = 2 * 1024 * 1024,
    this.batchWindow = const Duration(seconds: 60),
    this.maxQueueSize = 500,
    this.maxRecordAge = const Duration(hours: 1),
    this.maxRetries = 3,
    this.metricsLogInterval = const Duration(minutes: 5),
    this.initialRetryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 20),
  });

  /// Maximum records per batch (AWS limit: 500)
  final int maxBatchRecords;

  /// Maximum batch size in bytes (AWS limit: 4MB)
  final int maxBatchBytes;

  /// Time window before auto-flushing batch
  final Duration batchWindow;

  /// Maximum queue size before eviction
  final int maxQueueSize;

  /// Maximum age of records before expiration
  final Duration maxRecordAge;

  /// Maximum retry attempts
  final int maxRetries;

  /// Interval for logging metrics
  final Duration metricsLogInterval;

  /// Initial delay for retry backoff
  final Duration initialRetryDelay;

  /// Maximum delay for retry backoff
  final Duration maxRetryDelay;
}

// ============================================================================
// Data Classes
// ============================================================================

/// Represents a Firehose record with raw data.
class FirehoseRecord {
  FirehoseRecord.text(String message)
      : data = Uint8List.fromList(utf8.encode('$message\n'));

  FirehoseRecord.json(Map<String, dynamic> payload)
      : data = Uint8List.fromList(utf8.encode('${jsonEncode(payload)}\n'));

  FirehoseRecord.fromBytes(this.data);

  final Uint8List data;
}

/// Represents a queued record with metadata for retry and expiration tracking.
@visibleForTesting
class QueuedRecord {
  QueuedRecord({
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  final Uint8List data;
  final DateTime createdAt;
  final int retryCount;

  int get sizeBytes => data.length;

  /// Creates a copy with an incremented retry count.
  QueuedRecord withIncrementedRetry() {
    return QueuedRecord(
      data: data,
      createdAt: createdAt,
      retryCount: retryCount + 1,
    );
  }
}

// ============================================================================
// Retry State
// ============================================================================

/// Manages retry state with exponential backoff.
@visibleForTesting
class RetryState {
  RetryState({
    Duration initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 20),
    Random? random,
  })  : currentDelay = initialDelay,
        _initialDelay = initialDelay,
        _random = random ?? Random();

  final Duration _initialDelay;
  final Duration maxDelay;
  final Random _random;

  Duration currentDelay;
  int consecutiveFailures = 0;
  bool isPaused = false;

  /// Calculates the next backoff delay with full jitter.
  Duration calculateNextDelay({required bool isThrottling}) {
    // Exponential backoff: double the delay, capped at maxDelay
    final backoff = Duration(
      milliseconds: min(
        currentDelay.inMilliseconds * 2,
        maxDelay.inMilliseconds,
      ),
    );

    currentDelay = backoff;

    // Full jitter: random value between 0 and backoff
    final jitter = _random.nextDouble();
    return Duration(milliseconds: (backoff.inMilliseconds * jitter).toInt());
  }

  /// Resets the retry state after a successful send.
  void reset() {
    currentDelay = _initialDelay;
    consecutiveFailures = 0;
  }
}

// ============================================================================
// Metrics
// ============================================================================

/// Tracks metrics for observability.
@visibleForTesting
class FirehoseMetrics {
  int recordsEnqueued = 0;
  int recordsSent = 0;
  int recordsDropped = 0;
  int batchesSent = 0;
  int partialFailures = 0;
  DateTime? lastSuccessTime;
  DateTime? lastFailureTime;

  void reset() {
    recordsEnqueued = 0;
    recordsSent = 0;
    recordsDropped = 0;
    batchesSent = 0;
    partialFailures = 0;
    lastSuccessTime = null;
    lastFailureTime = null;
  }

  String formatLog(int currentQueueDepth) {
    final lastSuccess = lastSuccessTime != null
        ? '${DateTime.now().difference(lastSuccessTime!).inSeconds}s ago'
        : 'never';

    return '[Firehose] Queue: $currentQueueDepth | Sent: $recordsSent | '
        'Dropped: $recordsDropped | Batches: $batchesSent | '
        'Partial failures: $partialFailures | Last success: $lastSuccess';
  }
}

// ============================================================================
// Abstractions for Dependency Injection
// ============================================================================

/// Abstract interface for HTTP operations.
abstract class FirehoseHttpClient {
  Future<FirehoseHttpResponse> send(AWSBaseHttpRequest request);
}

/// HTTP response wrapper.
class FirehoseHttpResponse {
  FirehoseHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}

/// Default implementation using AWS HTTP client.
class DefaultFirehoseHttpClient implements FirehoseHttpClient {
  DefaultFirehoseHttpClient({AWSHttpClient? httpClient})
      : _httpClient = httpClient ?? AWSHttpClient();

  final AWSHttpClient _httpClient;

  @override
  Future<FirehoseHttpResponse> send(AWSBaseHttpRequest request) async {
    final operation = _httpClient.send(request);
    final response = await operation.response;
    final body = await response.decodeBody();
    return FirehoseHttpResponse(
      statusCode: response.statusCode,
      body: body,
    );
  }
}

/// Abstract interface for request signing.
abstract class FirehoseRequestSigner {
  Future<AWSBaseHttpRequest> sign(
    AWSHttpRequest request, {
    required String region,
  });
}

/// Default implementation using AWS SigV4 signer.
class DefaultFirehoseRequestSigner implements FirehoseRequestSigner {
  DefaultFirehoseRequestSigner(this._signer);

  final sigv4.AWSSigV4Signer _signer;

  @override
  Future<AWSBaseHttpRequest> sign(
    AWSHttpRequest request, {
    required String region,
  }) async {
    final scope = sigv4.AWSCredentialScope(
      region: region,
      service: AWSService.firehose,
    );
    return _signer.sign(request, credentialScope: scope);
  }
}

/// Abstract interface for connectivity monitoring.
abstract class ConnectivityMonitor {
  Stream<bool> get onConnectivityChanged;
  Future<bool> get isConnected;
}

/// Default implementation using connectivity_plus.
class DefaultConnectivityMonitor implements ConnectivityMonitor {
  final Connectivity _connectivity = Connectivity();

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

/// Abstract interface for credentials provider.
abstract class FirehoseCredentialsProvider {
  Future<FirehoseRequestSigner?> getSigner();
  Future<void> refreshCredentials();
}

/// Result of a batch send operation.
class _BatchSendResult {
  const _BatchSendResult({
    this.hasPartialFailure = false,
    this.failedRecords = const [],
    this.successCount = 0,
  });

  static const success = _BatchSendResult();

  final bool hasPartialFailure;
  final List<QueuedRecord> failedRecords;
  final int successCount;
}

// ============================================================================
// Core Firehose Client (Testable)
// ============================================================================

/// Core Firehose client with injectable dependencies.
///
/// This class contains all the business logic and can be easily tested
/// by injecting mock dependencies.
class FirehoseClient {
  FirehoseClient({
    required this.region,
    required this.streamName,
    required FirehoseHttpClient httpClient,
    required FirehoseRequestSigner signer,
    FirehoseConfig config = const FirehoseConfig(),
    ConnectivityMonitor? connectivityMonitor,
    Random? random,
  })  : _httpClient = httpClient,
        _signer = signer,
        _config = config,
        _connectivityMonitor = connectivityMonitor,
        _retryState = RetryState(
          initialDelay: config.initialRetryDelay,
          maxDelay: config.maxRetryDelay,
          random: random,
        );

  final String region;
  final String streamName;
  final FirehoseHttpClient _httpClient;
  FirehoseRequestSigner _signer;
  final FirehoseConfig _config;
  final ConnectivityMonitor? _connectivityMonitor;

  // Queue management
  @visibleForTesting
  final List<QueuedRecord> pendingRecords = [];
  Timer? _batchTimer;
  Timer? _metricsTimer;

  // Retry state
  final RetryState _retryState;
  Timer? _retryTimer;

  // Metrics
  @visibleForTesting
  final FirehoseMetrics metrics = FirehoseMetrics();

  // Connectivity monitoring
  StreamSubscription<bool>? _connectivitySubscription;

  // Ensures PutRecordBatch calls are serialized
  Future<void> _sendQueue = Future.value();

  // Callback for credential refresh (set by AppAmplifyFirehose)
  Future<FirehoseRequestSigner?> Function()? onCredentialRefreshNeeded;

  /// Starts the client (sets up timers and connectivity monitoring).
  void start() {
    _setupConnectivityMonitoring();
    _ensureBatchTimerStarted();
  }

  /// Disposes resources (timers, subscriptions).
  void dispose() {
    _batchTimer?.cancel();
    _batchTimer = null;
    _metricsTimer?.cancel();
    _metricsTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Configuration getter for testing.
  @visibleForTesting
  FirehoseConfig get config => _config;

  /// Retry state getter for testing.
  @visibleForTesting
  RetryState get retryState => _retryState;

  /// Enqueues a record for sending.
  void enqueue(FirehoseRecord record) {
    final queuedRecord = QueuedRecord(
      data: record.data,
      createdAt: DateTime.now(),
    );
    _enqueueRecord(queuedRecord);

    if (_shouldFlushBatch()) {
      _scheduleBatchSend();
    }
  }

  /// Enqueues multiple records for sending.
  void enqueueAll(List<FirehoseRecord> records) {
    for (final record in records) {
      final queuedRecord = QueuedRecord(
        data: record.data,
        createdAt: DateTime.now(),
      );
      _enqueueRecord(queuedRecord);
    }

    if (_shouldFlushBatch()) {
      _scheduleBatchSend();
    }
  }

  /// Forces an immediate flush of the queue.
  Future<void> flush() async {
    _scheduleBatchSend();
    await _sendQueue;
  }

  /// Queue depth for monitoring.
  int get queueDepth => pendingRecords.length;

  /// Whether the client is paused (e.g., offline).
  bool get isPaused => _retryState.isPaused;

  // ============================================================================
  // Internal Methods
  // ============================================================================

  void _setupConnectivityMonitoring() {
    final monitor = _connectivityMonitor;
    if (monitor == null) return;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = monitor.onConnectivityChanged.listen(
      (isConnected) {
        if (!isConnected && !_retryState.isPaused) {
          _retryState.isPaused = true;
          log.info('Firehose paused: device offline');
        } else if (isConnected && _retryState.isPaused) {
          _retryState.isPaused = false;
          log.info('Firehose resumed: connectivity restored');

          if (pendingRecords.isNotEmpty) {
            _scheduleBatchSend();
          }
        }
      },
    );
  }

  void _removeExpiredRecords() {
    final now = DateTime.now();
    final sizeBefore = pendingRecords.length;
    pendingRecords.removeWhere(
      (record) => now.difference(record.createdAt) > _config.maxRecordAge,
    );
    final removed = sizeBefore - pendingRecords.length;
    if (removed > 0) {
      metrics.recordsDropped += removed;
      log.warning('Dropped $removed expired records from Firehose queue');
    }
  }

  void _evictOldestIfNeeded() {
    while (pendingRecords.length > _config.maxQueueSize) {
      pendingRecords.removeAt(0);
      metrics.recordsDropped++;
    }
  }

  void _enqueueRecord(QueuedRecord record) {
    _removeExpiredRecords();
    pendingRecords.add(record);
    metrics.recordsEnqueued++;
    _evictOldestIfNeeded();
  }

  bool _shouldFlushBatch() {
    if (pendingRecords.isEmpty) {
      return false;
    }

    if (pendingRecords.length >= _config.maxBatchRecords) {
      return true;
    }

    final totalSize = pendingRecords.fold<int>(
      0,
      (sum, record) => sum + record.sizeBytes,
    );
    if (totalSize >= _config.maxBatchBytes) {
      return true;
    }

    return false;
  }

  void _ensureBatchTimerStarted() {
    _batchTimer ??= Timer.periodic(_config.batchWindow, (_) {
      if (pendingRecords.isNotEmpty) {
        _scheduleBatchSend();
      }
    });

    _metricsTimer ??= Timer.periodic(_config.metricsLogInterval, (_) {
      log.info(metrics.formatLog(pendingRecords.length));
    });
  }

  void _scheduleBatchSend() {
    if (pendingRecords.isEmpty) {
      return;
    }

    if (_retryState.isPaused) {
      log.info('Firehose send paused (offline)');
      return;
    }

    _sendQueue = _sendQueue.then((_) => _processBatch()).catchError((e, st) {
      // Ensure the future chain doesn't break on unexpected errors
      log.severe('Unexpected error in Firehose batch processing', e, st);
    });
  }

  Future<void> _processBatch() async {
    if (pendingRecords.isEmpty) {
      return;
    }

    final batchRecords = _extractBatch();
    if (batchRecords.isEmpty) {
      return;
    }

    try {
      final result = await _sendBatch(batchRecords);

      // Remove the batch from the queue
      pendingRecords.removeRange(0, batchRecords.length);

      if (result.hasPartialFailure) {
        // Re-insert failed records at the front
        pendingRecords.insertAll(0, result.failedRecords);
        metrics.recordsSent += result.successCount;
        metrics.partialFailures++;
      } else {
        metrics.recordsSent += batchRecords.length;
      }

      metrics.batchesSent++;
      metrics.lastSuccessTime = DateTime.now();
      _retryState.reset();
    } catch (e, st) {
      log.warning('Firehose batch send failed', e, st);
      metrics.lastFailureTime = DateTime.now();
      _retryState.consecutiveFailures++;

      final failedRecords =
          batchRecords.where((r) => r.retryCount >= _config.maxRetries);
      if (failedRecords.isNotEmpty) {
        pendingRecords.removeWhere((r) => failedRecords.contains(r));
        metrics.recordsDropped += failedRecords.length;
        log.warning(
            'Dropped ${failedRecords.length} records after max retries');
      }

      if (_retryState.consecutiveFailures < _config.maxRetries) {
        final delay = _retryState.calculateNextDelay(
          isThrottling: isThrottlingError(e),
        );
        log.info('Scheduling Firehose retry in ${delay.inSeconds}s');
        _retryTimer?.cancel();
        _retryTimer = Timer(delay, _scheduleBatchSend);
      }
    }
  }

  List<QueuedRecord> _extractBatch() {
    final batchRecords = <QueuedRecord>[];
    var batchSize = 0;

    for (final record in pendingRecords) {
      if (batchRecords.length >= _config.maxBatchRecords) {
        break;
      }
      if (batchSize + record.sizeBytes > _config.maxBatchBytes) {
        break;
      }
      batchRecords.add(record);
      batchSize += record.sizeBytes;
    }

    return batchRecords;
  }

  Future<_BatchSendResult> _sendBatch(
    List<QueuedRecord> batchRecords, {
    bool isRetryAfterRefresh = false,
  }) async {
    final body = jsonEncode({
      'DeliveryStreamName': streamName,
      'Records': batchRecords
          .map((record) => {'Data': base64.encode(record.data)})
          .toList(),
    });

    final request = AWSHttpRequest(
      method: AWSHttpMethod.post,
      uri: Uri(
        scheme: 'https',
        host: 'firehose.$region.amazonaws.com',
        path: '/',
      ),
      headers: const {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'Firehose_20150804.PutRecordBatch',
      },
      body: Uint8List.fromList(utf8.encode(body)),
    );

    final signedRequest = await _signer.sign(request, region: region);
    final response = await _httpClient.send(signedRequest);

    if (response.statusCode >= 300) {
      // Check for expired token (400 with ExpiredTokenException) or forbidden (403)
      final isExpiredToken = response.statusCode == 400 &&
          response.body.contains('ExpiredTokenException');
      if (response.statusCode == 403 || isExpiredToken) {
        // Only refresh credentials on the first attempt (not on retry)
        if (!isRetryAfterRefresh) {
          log.warning('Firehose authentication failed, refreshing credentials');
          final refreshCallback = onCredentialRefreshNeeded;
          if (refreshCallback != null) {
            final newSigner = await refreshCallback();
            if (newSigner != null) {
              _signer = newSigner;
              log.info('Retrying batch with refreshed credentials');
              return _sendBatch(batchRecords, isRetryAfterRefresh: true);
            }
          }
        }
        throw Exception('Authentication failed: ${response.body}');
      }

      if (!isRetryableError(response.statusCode, response.body)) {
        metrics.recordsDropped += batchRecords.length;
        log.severe(
          'Non-retryable Firehose error (${response.statusCode}): ${response.body}',
        );
        // Return empty result - caller will remove the batch
        return _BatchSendResult.success;
      }

      throw Exception(
        'Firehose request failed (${response.statusCode}): ${response.body}',
      );
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final failedPutCount = responseJson['FailedPutCount'] as int? ?? 0;

    if (failedPutCount > 0) {
      return _parsePartialFailure(responseJson, batchRecords);
    }

    return _BatchSendResult.success;
  }

  _BatchSendResult _parsePartialFailure(
    Map<String, dynamic> responseJson,
    List<QueuedRecord> batchRecords,
  ) {
    final requestResponses = responseJson['RequestResponses'] as List<dynamic>?;
    if (requestResponses == null) {
      return _BatchSendResult.success;
    }

    final failedRecords = <QueuedRecord>[];
    var droppedCount = 0;

    for (var i = 0;
        i < requestResponses.length && i < batchRecords.length;
        i++) {
      final response = requestResponses[i] as Map<String, dynamic>;
      final errorCode = response['ErrorCode'] as String?;

      if (errorCode != null) {
        final originalRecord = batchRecords[i];
        final retriedRecord = originalRecord.withIncrementedRetry();

        if (retriedRecord.retryCount < _config.maxRetries) {
          failedRecords.add(retriedRecord);
        } else {
          droppedCount++;
        }
      }
    }

    if (droppedCount > 0) {
      metrics.recordsDropped += droppedCount;
    }

    if (failedRecords.isNotEmpty) {
      log.warning(
          '${failedRecords.length} records failed in batch, re-enqueuing');

      return _BatchSendResult(
        hasPartialFailure: true,
        failedRecords: failedRecords,
        successCount: batchRecords.length - failedRecords.length - droppedCount,
      );
    }

    return _BatchSendResult(successCount: batchRecords.length - droppedCount);
  }

  /// Classifies if an error is retryable based on status code and response.
  @visibleForTesting
  static bool isRetryableError(int statusCode, String responseBody) {
    if (statusCode == 429 || statusCode == 503) {
      return true;
    }

    if (statusCode == 500 || statusCode == 502 || statusCode == 504) {
      return true;
    }

    if (responseBody.contains('ServiceUnavailableException') ||
        responseBody.contains('InternalFailure')) {
      return true;
    }

    return false;
  }

  /// Checks if an error is a throttling error.
  @visibleForTesting
  static bool isThrottlingError(Object error) {
    final errorStr = error.toString();
    return errorStr.contains('429') ||
        errorStr.contains('503') ||
        errorStr.contains('ServiceUnavailableException') ||
        errorStr.contains('Throttling');
  }
}

// ============================================================================
// Production Facade
// ============================================================================

/// High-level facade for AppAmplifyFirehose.
///
/// This class manages Amplify configuration and provides a convenient
/// interface for production use. For testing, use [FirehoseClient] directly.
///
/// Use [instance] for the shared production instance, or create separate
/// instances for testing.
class AppAmplifyFirehose {
  AppAmplifyFirehose();

  static AppAmplifyFirehose? _instance;

  /// Returns the shared instance for production use.
  static AppAmplifyFirehose get instance => _instance ??= AppAmplifyFirehose();

  FirehoseClient? _client;
  String? _region;
  Completer<void>? _configureCompleter;

  /// Returns the underlying client for advanced usage.
  /// Returns null if not configured.
  FirehoseClient? get client => _client;

  /// Whether the firehose is configured and ready.
  bool get isConfigured => _client != null;

  Future<void> ensureConfigured({
    required String region,
    required String identityPoolId,
    required String streamName,
    FirehoseConfig config = const FirehoseConfig(),
  }) async {
    if (_client != null) {
      return;
    }

    if (_configureCompleter != null) {
      return _configureCompleter!.future;
    }

    _configureCompleter = Completer<void>();

    try {
      await _configureAmplify(
        region: region,
        identityPoolId: identityPoolId,
      );

      final signer = await _createSigner();
      if (signer == null) {
        throw Exception('Unable to create signer');
      }

      _region = region;

      _client = FirehoseClient(
        region: region,
        streamName: streamName,
        httpClient: DefaultFirehoseHttpClient(),
        signer: signer,
        config: config,
        connectivityMonitor: DefaultConnectivityMonitor(),
      );

      _client!.onCredentialRefreshNeeded = _refreshCredentials;
      _client!.start();

      _configureCompleter?.complete();
    } catch (e, st) {
      log.severe('Failed to configure Amplify Firehose', e, st);
      _configureCompleter?.completeError(e, st);
      _configureCompleter = null;
      rethrow;
    }
  }

  Future<FirehoseRequestSigner?> _createSigner(
      {bool forceRefresh = false}) async {
    final session = await Amplify.Auth.fetchAuthSession(
      options: FetchAuthSessionOptions(
        forceRefresh: forceRefresh,
        pluginOptions:
            const amplify_auth.CognitoFetchAuthSessionPluginOptions(),
      ),
    ) as amplify_auth.CognitoAuthSession;

    final creds = session.credentialsResult.valueOrNull;
    if (creds == null) {
      return null;
    }

    final signer = sigv4.AWSSigV4Signer(
      credentialsProvider: sigv4.AWSCredentialsProvider(
        sigv4.AWSCredentials(
          creds.accessKeyId,
          creds.secretAccessKey,
          creds.sessionToken,
        ),
      ),
    );

    return DefaultFirehoseRequestSigner(signer);
  }

  Future<FirehoseRequestSigner?> _refreshCredentials() async {
    log.info('Refreshing Firehose credentials');
    return await _createSigner(forceRefresh: true);
  }

  /// Disposes resources.
  void dispose() {
    _client?.dispose();
    _client = null;
    _configureCompleter = null;
  }

  /// Enqueues stats for sending.
  Future<void> enqueueStats({
    required FirehoseStreamType streamType,
    required String userId,
    required String sessionId,
    required Map<String, dynamic> stats,
  }) async {
    final client = _client;
    if (client == null || stats.isEmpty) {
      return;
    }

    final record = FirehoseRecord.json({
      ...stats,
      'user_id': userId,
      'session_id': sessionId,
      'source_type': streamType.name,
      'region': _region,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    });

    client.enqueueAll([record]);
  }

  /// Enqueues log messages for sending.
  Future<void> enqueueLogs({
    required List<String> messages,
    String? instanceId,
    String? level,
    String? source,
  }) async {
    final client = _client;
    if (client == null || messages.isEmpty) {
      return;
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final records = messages.map((message) {
      return FirehoseRecord.text(
        [
          if (now.isNotEmpty) '[$now]',
          if (level != null) '[${level.toUpperCase()}]',
          if (instanceId != null) '[instance:$instanceId]',
          if (source != null) '[source:$source]',
          message,
        ].join(' '),
      );
    }).toList();

    client.enqueueAll(records);
  }

  /// Forces an immediate flush.
  Future<void> flush() async {
    await _client?.flush();
  }

  Future<void> _configureAmplify({
    required String region,
    required String identityPoolId,
  }) async {
    if (!Amplify.isConfigured) {
      final auth = amplify_auth.AmplifyAuthCognito();

      try {
        await Amplify.addPlugin(auth);
      } on Exception catch (e, st) {
        log.warning('Amplify addPlugin skipped', e, st);
      }

      final config = jsonEncode({
        'auth': {
          'plugins': {
            'awsCognitoAuthPlugin': {
              'IdentityManager': {'Default': {}},
              'CredentialsProvider': {
                'CognitoIdentity': {
                  'Default': {
                    'PoolId': identityPoolId,
                    'Region': region,
                  }
                }
              },
              'Auth': {
                'Default': {'authenticationFlowType': 'USER_SRP_AUTH'}
              }
            }
          }
        }
      });

      try {
        await Amplify.configure(config);
      } on AmplifyAlreadyConfiguredException {
        log.info('Amplify already configured; skipping configure.');
      }
    }
  }
}
