import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/src/messages/incoming_message_queue.dart';

class Msg {
  int seq;
  Msg(this.seq);
}

void main() {
  test('messages in order', () {
    //arrange
    final q = IncomingMessageQueue<Msg>();

    //action
    q.addMessage(0, Msg(0));
    Msg? m0 = q.popNextMessage();

    //assert
    expect(m0!.seq, 0);
  });

  test('messages out of order', () {
    //arrange
    final q = IncomingMessageQueue<Msg>();

    //action
    q.addMessage(1, Msg(1));
    Msg? m0 = q.popNextMessage();

    q.addMessage(0, Msg(0));
    Msg? m1 = q.popNextMessage();
    Msg? m2 = q.popNextMessage();

    //assert
    expect(m0, isNull);
    expect(m1!.seq, 0);
    expect(m2!.seq, 1);
  });

  test('duplicate messages', () {
    //arrange
    final q = IncomingMessageQueue<Msg>();

    //action
    q.addMessage(0, Msg(0));
    Msg? m0 = q.popNextMessage();

    q.addMessage(1, Msg(1));
    Msg? m1 = q.popNextMessage();

    q.addMessage(1, Msg(1));
    Msg? m2 = q.popNextMessage();

    //assert
    expect(m0!.seq, 0);
    expect(m1!.seq, 1);
    expect(m2, isNull);
  });
}
