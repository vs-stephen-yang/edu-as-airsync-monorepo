import 'package:display_flutter/utility/debounced_stream_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebouncedStreamController', () {
    test('Only last value is emitted after debounce duration', () {
      fakeAsync((async) {
        final List<int> values = [];
        final controller = DebouncedStreamController<int>(
            delay: const Duration(milliseconds: 300));
        controller.stream.listen(values.add);

        controller.add(1);
        async.elapse(const Duration(milliseconds: 100));
        controller.add(2);
        async.elapse(const Duration(milliseconds: 100));
        controller.add(3);
        async.elapse(const Duration(milliseconds: 300));

        expect(values, [3]);

        controller.dispose();
      });
    });

    test(
        'First emits due to sufficient time, others are suppressed by debounce',
        () {
      fakeAsync((async) {
        final List<int> values = [];
        final controller = DebouncedStreamController<int>(
            delay: const Duration(milliseconds: 200));
        controller.stream.listen(values.add);

        // 第一次事件，會在 debounce 後成功發送
        controller.add(1);
        async.elapse(const Duration(milliseconds: 250)); // 發出 1

        // 接下來連續快速加三筆，會被 debounce 掉，只留最後一筆
        controller.add(2);
        async.elapse(const Duration(milliseconds: 50));
        controller.add(3);
        async.elapse(const Duration(milliseconds: 50));
        controller.add(4);
        async.elapse(const Duration(milliseconds: 250)); // 應該只發出 4

        expect(values, [1, 4]);

        controller.dispose();
      });
    });
    test('Does not emit if disposed before delay', () {
      fakeAsync((async) {
        final List<int> values = [];
        final controller = DebouncedStreamController<int>(
            delay: const Duration(milliseconds: 300));
        controller.stream.listen(values.add);

        controller.add(42);
        async.elapse(const Duration(milliseconds: 100));
        controller.dispose();
        async.elapse(const Duration(milliseconds: 300));

        expect(values, isEmpty);
      });
    });

    test('Can emit multiple values over separated debounce windows', () {
      fakeAsync((async) {
        final List<int> values = [];
        final controller = DebouncedStreamController<int>(
            delay: const Duration(milliseconds: 200));
        controller.stream.listen(values.add);

        controller.add(1);
        async.elapse(const Duration(milliseconds: 250));
        controller.add(2);
        async.elapse(const Duration(milliseconds: 250));

        expect(values, [1, 2]);

        controller.dispose();
      });
    });
  });
}
