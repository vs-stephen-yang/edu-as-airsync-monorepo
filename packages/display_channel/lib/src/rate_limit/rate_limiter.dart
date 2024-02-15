import 'dart:async';

import 'package:clock/clock.dart';
import 'package:display_channel/src/rate_limit/token_bucket.dart';

class RateLimiter {
  final int capacity;
  final double refillRate; // requests per second

  final Duration maxBucketAge; // Maximum age of a bucket before cleanup
  final Map<String, TokenBucket> _buckets = {};

  int get bucketCount => _buckets.length;

  Timer? _cleanupTimer;
  final Duration cleanupInterval;

  RateLimiter(
    this.capacity,
    this.refillRate, {
    this.maxBucketAge = const Duration(minutes: 1),
    this.cleanupInterval = const Duration(minutes: 10),
  });

  void start() {
    _cleanupTimer = Timer.periodic(cleanupInterval, (timer) {
      _cleanup(clock.now());
    });
  }

  void stop() {
    _cleanupTimer?.cancel();
  }

  // remove stale buckets
  void _cleanup(DateTime now) {
    _buckets.removeWhere(
      (_, bucket) => now.difference(bucket.lastAccessTime) >= maxBucketAge,
    );
  }

  bool allowRequest(String key) {
    if (!_buckets.containsKey(key)) {
      _buckets[key] = TokenBucket(capacity, refillRate);
    }

    return _buckets[key]!.tryConsume(1);
  }
}
