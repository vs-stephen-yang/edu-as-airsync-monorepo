import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/src/rate_limit/token_bucket.dart';

List<bool> consume(TokenBucket bucket, int count) {
  final results = <bool>[];
  for (var i = 0; i < count; i++) {
    results.add(bucket.tryConsume(1));
  }
  return results;
}

void main() {
  test('Requests allowed within rate limit ', () {
    fakeAsync((async) {
      // arrange
      final bucket = TokenBucket(10, 1); // Allow 1 tokens per second

      // action
      // Attempt 10 requests within 1 second
      final results = consume(bucket, 10);

      // assert
      expect(results.every((result) => result == true), isTrue);
    });
  });

  test('Requests blocked when exceeding rate limit', () {
    fakeAsync((async) {
      // arrange
      final bucket = TokenBucket(10, 1); // Allow 1 tokens per second

      // action
      // Attempt 11 requests within 1 second
      final results = consume(bucket, 11);

      // assert
      // the 11th request is blocked
      expect(results[10], isFalse);
    });
  });

  test('Tokens should not accumulate beyond its capacity', () {
    fakeAsync((async) {
      // arrange
      final bucket = TokenBucket(10, 1); // Allow 1 tokens per second

      // action
      async.elapse(const Duration(minutes: 100));
      final results = consume(bucket, 11);

      // assert
      // the 11th request is blocked
      expect(results[10], isFalse);
    });
  });

  test('Tokens should refill', () {
    fakeAsync((async) {
      // arrange
      final bucket = TokenBucket(10, 1); // Allow 10 tokens per second
      consume(bucket, 10);

      // action
      async.elapse(const Duration(seconds: 5));
      final results = consume(bucket, 6);

      // assert
      expect(results.sublist(0, 5).every((result) => result == true), isTrue);
      expect(results[5], isFalse);
    });
  });
}
