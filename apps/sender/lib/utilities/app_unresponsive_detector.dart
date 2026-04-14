import 'dart:async';

// Detect when the app becomes unresponsive,
// whether due to a suspension (when the OS pauses the app) or a freeze (due to internal app issues).
class AppUnresponsiveDetector {
  static AppUnresponsiveDetector? _instance;

  static AppUnresponsiveDetector get instance => _instance!;

  Timer? _timer;
  final Duration _checkInterval;
  final Duration _unresponsiveThreshold;

  DateTime? _lastCheckTime;

  // List of listeners
  final List<void Function(Duration)> _listeners = [];

  AppUnresponsiveDetector._internal(
    this._checkInterval,
    this._unresponsiveThreshold,
  ) {
    _startMonitoring();
  }

  static void initialize({
    Duration checkInterval = const Duration(seconds: 2),
    Duration unresponsiveThreshold = const Duration(seconds: 10),
  }) {
    // ensures that the class is only initialized once.
    assert(_instance == null);
    assert(unresponsiveThreshold > checkInterval);

    _instance = AppUnresponsiveDetector._internal(
      checkInterval,
      unresponsiveThreshold,
    );
  }

  void _startMonitoring() {
    _lastCheckTime = DateTime.now();

    _timer = Timer.periodic(_checkInterval, _onTimeout);
  }

  void _onTimeout(Timer timer) {
    final currentTime = DateTime.now();

    final timeSinceLastCheck = currentTime.difference(_lastCheckTime!);

    // If the time since the last check is greater than the threshold, notify unresponsive
    if (timeSinceLastCheck > _unresponsiveThreshold) {
      _notifyListeners(timeSinceLastCheck);
    }

    _lastCheckTime = currentTime;
  }

  // Add a listener for events
  void addListener(void Function(Duration) listener) {
    _listeners.add(listener);
  }

  // Remove a listener for events
  void removeListener(void Function(Duration) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners(Duration unresponsiveDuration) {
    for (var listener in _listeners) {
      listener(unresponsiveDuration);
    }
  }

  // Clean up resources
  void dispose() {
    _timer?.cancel();
  }
}
