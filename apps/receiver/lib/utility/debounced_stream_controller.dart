import 'dart:async';

class DebouncedStreamController<T> {
  final Duration delay;
  final StreamController<T> _controller = StreamController<T>.broadcast();
  Timer? _debounceTimer;

  DebouncedStreamController({required this.delay});

  void add(T value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      _controller.add(value);
    });
  }

  Stream<T> get stream => _controller.stream;

  void dispose() {
    _debounceTimer?.cancel();
    _controller.close();
  }
}
