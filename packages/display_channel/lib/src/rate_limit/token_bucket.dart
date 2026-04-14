import 'package:clock/clock.dart';

class TokenBucket {
  final int capacity;
  final double refillRate; // tokens per second
  int _tokens;
  late DateTime _lastRefillTime;

  DateTime get lastAccessTime => _lastRefillTime;

  TokenBucket(
    this.capacity,
    this.refillRate,
  ) : _tokens = capacity {
    _lastRefillTime = clock.now();
  }

  void _refill(DateTime now) {
    final elapsed = now.difference(_lastRefillTime);
    final refillAmount = (elapsed.inMilliseconds * refillRate / 1000).floor();

    if (refillAmount > 0) {
      _tokens = (_tokens + refillAmount).clamp(0, capacity);
      _lastRefillTime = now;
    }
  }

  bool tryConsume(int tokens) {
    final now = clock.now();
    _refill(now);

    if (_tokens >= tokens) {
      _tokens -= tokens;
      return true;
    }
    return false;
  }
}
