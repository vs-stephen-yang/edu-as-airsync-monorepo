import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/providers/channel_server.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChannelServer createServer(List<bool> emitted) {
    return ChannelServer(
      onNewDirectChannel: (_, __) {},
      onNewTunnelChannel: (_) {},
      verifyConnectRequest: (_, {required isDirectConnect}) =>
          ConnectRequestStatus.success,
      onTunnelStatusChange: (_) {},
      onDisplayCodeChange: () {},
      baseApiUrl: 'https://test.api',
      instanceId: 'abc-123',
      webTransportServerPort: 1234,
      reportPortBindResult: (_, __, ___) {},
      reportTunnelConnectResult: (_, __) {},
      reportWebTransportCertDate: (_) {},
    )..tunnelActivatedStream.stream.listen(emitted.add);
  }

  group('ChannelServer - tunnelActivatedStream debounce', () {
    test('Only emits once after rapid enable/disable changes', () {
      fakeAsync((async) {
        final List<bool> emitted = [];
        final server = createServer(emitted);

        server.enableTunnel(true); // status = checking
        async.elapse(const Duration(milliseconds: 100));
        server.enableTunnel(false); // status = disabled
        async.elapse(const Duration(milliseconds: 100));
        server.enableTunnel(true); // status = checking again

        expect(emitted.length, 0); // 還沒 debounce

        async.elapse(const Duration(milliseconds: 300)); // debounce 發動

        expect(emitted.length, 1);
        expect(emitted.single, false);
      });
    });

    test('Does not emit if status does not change within debounce window', () {
      fakeAsync((async) {
        final List<bool> emitted = [];
        final server = createServer(emitted);

        server.enableTunnel(true); // checking
        async.elapse(const Duration(milliseconds: 100));
        server.enableTunnel(true); // same again
        async.elapse(const Duration(milliseconds: 300));

        expect(emitted.length, 1);
        expect(emitted.single, false);
      });
    });

    test('Emits false if tunnel is left in checking after debounce', () {
      fakeAsync((async) {
        final List<bool> emitted = [];
        final server = createServer(emitted);

        server.enableTunnel(true);
        async.elapse(const Duration(milliseconds: 350));

        expect(emitted.length, 1);
        expect(emitted.single, false);
      });
    });
  });
}
