import 'dart:async';

import 'package:display_channel/src/messages/channel_message.dart';

class ExpectValueCompleter<T> {
  final completer = Completer();
  final T _expectValue;

  ExpectValueCompleter(this._expectValue);

  void updateValue(T value) {
    if (_expectValue == value) {
      completer.complete();
    }
  }
}

List<ChannelMessage> buildMessages(
  List<int> sequencesOfMessages,
  bool shouldFillSequence,
) {
  final messages = <ChannelMessage>[];

  for (var sequence in sequencesOfMessages) {
    final message = StartPresentMessage(sequence.toString());

    if (shouldFillSequence) {
      message.seq = sequence;
    }

    messages.add(message);
  }

  return messages;
}

//  take the last n elements from a list
List<T> lastN<T>(List<T> list, int n) {
  // Ensure n is greater than or equal to the length of the list
  assert(n <= list.length,
      'n must be greater than or equal to the length of the list');

  return list.sublist(list.length - n);
}
