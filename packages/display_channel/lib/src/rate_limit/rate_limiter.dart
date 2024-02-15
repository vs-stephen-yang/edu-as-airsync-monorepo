import 'package:display_channel/src/rate_limit/token_bucket.dart';

class RateLimiter {
  final int capacity;
  final double refillRate; // requests per second

  final Duration maxBucketAge; // Maximum age of a bucket before cleanup
  final Map<String, TokenBucket> _buckets = {};

  int get bucketCount => _buckets.length;

  RateLimiter(
    this.capacity,
    this.refillRate, {
    this.maxBucketAge = const Duration(minutes: 1),
  });

  void cleanup(DateTime now) {
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
