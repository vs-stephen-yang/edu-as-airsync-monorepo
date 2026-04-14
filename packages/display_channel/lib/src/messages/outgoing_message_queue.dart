import 'dart:math';

class OutgoingMessageQueue<T> {
  int _nextSequenceNumber = 0;

  final _messages = [];

  int get nextSequenceNumber => _nextSequenceNumber;
  int get length => _messages.length;
  int get earliestMessageSequenceNumber =>
      _nextSequenceNumber - _messages.length;

  // return the sequence number of this message
  int pushMessage(T message) {
    int sequenceNumber = _nextSequenceNumber;

    _messages.add(message);
    _nextSequenceNumber += 1;

    return sequenceNumber;
  }

  T? getMessage(int sequenceNumber) {
    final index = sequenceNumber - earliestMessageSequenceNumber;
    if (index < 0) {
      return null;
    }

    return _messages[index];
  }

  // Remove all messages up to and NOT including the given targetSequenceNumber
  void removeMessagesBefore(int targetSequenceNumber) {
    if (_messages.isEmpty) {
      return;
    }

    int index = targetSequenceNumber - earliestMessageSequenceNumber;

    if (index < 0) {
      return;
    }

    final end = min(index, _messages.length);
    _messages.removeRange(0, end);
  }
}
