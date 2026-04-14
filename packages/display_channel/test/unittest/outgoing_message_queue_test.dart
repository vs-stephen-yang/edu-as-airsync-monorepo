import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/src/messages/outgoing_message_queue.dart';

class Msg {
  int seq;
  Msg(this.seq);
}

void main() {
  late OutgoingMessageQueue<Msg> q;

  setUp(() {
    q = OutgoingMessageQueue<Msg>();
  });

  test('Assign sequence number in order', () {
    //arrange

    //action
    int s1 = q.pushMessage(Msg(0));
    int s2 = q.pushMessage(Msg(1));

    //assert
    expect(s1, 0);
    expect(s2, 1);
  });

  test('Remove messages one by one', () {
    //arrange

    //action
    q.pushMessage(Msg(0));
    q.pushMessage(Msg(1));

    q.removeMessagesBefore(1);
    final m1 = q.getMessage(0);
    final m2 = q.getMessage(1);

    q.removeMessagesBefore(2);
    final m3 = q.getMessage(1);

    //assert
    expect(m1, null);
    expect(m2!.seq, 1);
    expect(m3, null);
    expect(q.length, 0);
  });

  test('Remove all the messages', () {
    //arrange

    //action
    q.pushMessage(Msg(0));
    q.pushMessage(Msg(1));

    q.removeMessagesBefore(2);

    //assert
    expect(q.length, 0);
  });

  test('Remove an empty queue', () {
    //arrange

    //action
    q.pushMessage(Msg(0));
    q.pushMessage(Msg(1));

    q.removeMessagesBefore(2);
    q.removeMessagesBefore(2);

    //assert
    expect(q.length, 0);
  });

  test('Remove messages larger than those in the queue', () {
    //arrange

    //action
    q.pushMessage(Msg(0));
    q.pushMessage(Msg(1));

    q.removeMessagesBefore(3);

    //assert
    expect(q.length, 0);
  });
}
