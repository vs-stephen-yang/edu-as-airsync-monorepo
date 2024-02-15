import 'package:display_channel/src/rate_limit/rate_limiter.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

List<bool> allowRequest(RateLimiter limiter, String id, int count) {
  final results = <bool>[];

  for (var i = 0; i < count; i++) {
    results.add(limiter.allowRequest(id));
  }
  return results;
}

void main() {
  late RateLimiter limiter;

  setUp(() {
    limiter = RateLimiter(
      5, // capacity 5
      2, // Allow 2 tokens per second
      maxBucketAge: const Duration(minutes: 2),
      cleanupInterval: const Duration(minutes: 2),
    );
  });

  test('should limit the rate', () {
    fakeAsync((async) {
      // arrange
      limiter.start();

      // action
      // Attempt 5 requests within 1 second
      final results1 = allowRequest(limiter, 'id1', 6);
      final results2 = allowRequest(limiter, 'id2', 6);

      // assert
      expect(results1.sublist(0, 5).every((result) => result == true), isTrue);
      expect(results1[5], isFalse);

      expect(results2.sublist(0, 5).every((result) => result == true), isTrue);
      expect(results2[5], isFalse);
    });
  });

  test('the stale buckets should be cleaned up', () {
    fakeAsync((async) {
      // arrange
      limiter.start();

      limiter.allowRequest('id1');
      limiter.allowRequest('id2');

      // action
      async.elapse(const Duration(minutes: 3));

      // assert
      expect(limiter.bucketCount, 0);
    });
  });

  test('the active buckets should not be cleaned up', () {
    fakeAsync((async) {
      // arrange
      limiter.start();

      limiter.allowRequest('id1');
      limiter.allowRequest('id2');

      // action
      async.elapse(const Duration(seconds: 119));

      // assert
      expect(limiter.bucketCount, 2);
    });
  });
}
