import 'dart:async';
import 'dart:convert';
import 'package:display_flutter/utility/caching_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:fake_async/fake_async.dart';

/// A minimal fake HTTP client that simulates sending requests.
/// It now stores each sent StreamedRequest for later inspection.
class FakeClient extends BaseClient {
  int callCount = 0;
  bool succeed;
  final List<StreamedRequest> requests = [];

  FakeClient({this.succeed = true});

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    callCount++;
    if (request is StreamedRequest) {
      requests.add(request);
    }
    if (succeed) return StreamedResponse(const Stream.empty(), 200);
    throw Exception('Failure');
  }
}

void main() {
  late FakeClient fakeClient;
  late CachingHttpClient cachingClient;

  CachingHttpClient createClient() => CachingHttpClient(
        innerClient: fakeClient,
        requestTimeout: const Duration(seconds: 2),
        options: const CachingHttpClientOptions(
          minRetryDelay: Duration(milliseconds: 100),
          initialRetryDelay: Duration(seconds: 5),
          maxRetryDelay: Duration(minutes: 1),
          maxRequestAge: Duration(minutes: 2),
          maxQueueLength: 60,
        ),
      );

  setUp(() {
    fakeClient = FakeClient(succeed: true);
    cachingClient = createClient();
  });

  test('cached request is eventually sent', () {
    fakeAsync((async) {
      // Arrange
      final request = Request('GET', Uri.parse('http://example.com'));

      // Act
      cachingClient.send(request);
      async.flushMicrotasks();
      async.flushTimers();

      // Assert
      expect(fakeClient.callCount, equals(1));
    });
  });

  test('drops excess requests', () {
    fakeAsync((async) {
      // Arrange
      const totalRequests = 70;
      for (var i = 0; i < totalRequests; i++) {
        cachingClient.send(Request('GET', Uri.parse('http://example.com/$i')));
        async.flushMicrotasks();
      }

      // Act
      async.flushTimers();

      // Assert: Only 60 requests (the maxQueueLength) should be processed.
      expect(fakeClient.callCount, equals(60));

      expect(fakeClient.requests[0].url.toString(),
          equals('http://example.com/10'));
      expect(fakeClient.requests[59].url.toString(),
          equals('http://example.com/69'));
    });
  });

  test('drops requests that are too old', () {
    fakeAsync((async) {
      // Arrange
      fakeClient.succeed = false;
      final request = Request('GET', Uri.parse('http://example.com/'));
      cachingClient.send(request);
      async.flushMicrotasks();

      // Act: Advance time beyond maxRequestAge.
      async.flushTimers();

      // Assert: The request should be retried 5 times and dropped.
      expect(fakeClient.callCount, equals(5));
    });
  });

  test('applies exponential backoff on failure', () {
    fakeAsync((async) {
      // Arrange
      fakeClient.succeed = false;
      cachingClient.send(Request('GET', Uri.parse('http://example.com/')));
      async.flushMicrotasks();

      // Act: Advance time enough for 3 retries.
      async.elapse(const Duration(seconds: 1));
      async.elapse(const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 10));

      // Assert: Expect 3 attempts.
      expect(fakeClient.callCount, equals(3));
    });
  });

  test('flush resets backoff timer', () {
    fakeAsync((async) {
      // Arrange
      fakeClient.succeed = false;
      cachingClient.send(Request('GET', Uri.parse('http://example.com/')));
      async.flushMicrotasks();

      // Act: Advance time for 2 retries, then flush to reset.
      async.elapse(const Duration(seconds: 1));
      async.elapse(const Duration(seconds: 5));
      cachingClient.flush();

      async.elapse(const Duration(milliseconds: 100));

      // Assert
      expect(fakeClient.callCount, equals(3));
    });
  });

  test('sends full HTTP request with headers and body', () {
    fakeAsync((async) {
      // Arrange
      final url = Uri.parse('http://example.com/data');
      const body = '{"key":"value"}';
      final req = Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Content-Length'] = body.length.toString()
        ..body = body;
      cachingClient.send(req);
      async.flushMicrotasks();

      // Act
      async.flushTimers();

      // Assert: Verify headers.
      final sentReq = fakeClient.requests.last;
      expect(sentReq.headers['Content-Type'], startsWith('application/json'));
      expect(sentReq.headers['Content-Length'], equals(body.length.toString()));

      // Assert: Verify body.
      final collected = <int>[];
      final completer = Completer<void>();
      sentReq.finalize().listen(collected.addAll, onDone: completer.complete);
      async.flushMicrotasks();
      async.flushTimers();
      completer.future.then((_) {
        expect(utf8.decode(collected), equals(body));
      });
    });
  });

  test('verifies content of requests for multiple requests', () {
    fakeAsync((async) {
      // Arrange: Create two POST requests with distinct content.
      final url1 = Uri.parse('http://example.com/data1');
      final req1 = Request('POST', url1);

      final url2 = Uri.parse('http://example.com/data2');
      final req2 = Request('POST', url2);

      // Act: Send both requests.
      cachingClient.send(req1);
      async.flushMicrotasks();

      cachingClient.send(req2);
      async.flushMicrotasks();

      async.flushTimers();

      // Assert: Verify that two requests were processed.
      expect(fakeClient.requests.length, equals(2));

      // Check the content of the first request.
      final sentReq1 = fakeClient.requests[0];
      expect(sentReq1.url.toString(), equals('http://example.com/data1'));
      final sentReq2 = fakeClient.requests[1];
      expect(sentReq2.url.toString(), equals('http://example.com/data2'));
    });
  });

  test('handles two sequential requests one after the other', () {
    fakeAsync((async) {
      // Arrange: Create two distinct requests.
      final req1 = Request('GET', Uri.parse('http://example.com/1'));
      final req2 = Request('GET', Uri.parse('http://example.com/2'));

      // Act: Send the first request.
      cachingClient.send(req1);
      async.flushMicrotasks();
      async.flushTimers();

      // Then send the second request.
      cachingClient.send(req2);
      async.flushMicrotasks();
      async.flushTimers();

      // Assert: Verify that two requests were processed in order.
      expect(fakeClient.requests.length, equals(2));
      expect(fakeClient.requests[0].url.toString(),
          equals('http://example.com/1'));
      expect(fakeClient.requests[1].url.toString(),
          equals('http://example.com/2'));
    });
  });

  test('initially fails and later succeeds after retries', () {
    fakeAsync((async) {
      // Arrange
      fakeClient.succeed = false;
      final request = Request('GET', Uri.parse('http://example.com/retry'));
      cachingClient.send(request);
      async.flushMicrotasks();

      // Act: Advance time to trigger 2 retry attempts.
      async.elapse(const Duration(seconds: 1));
      async.elapse(const Duration(seconds: 5));

      // Now switch to success.
      fakeClient.succeed = true;
      async.flushTimers();

      // Assert
      expect(fakeClient.callCount, equals(3));
    });
  });
}
