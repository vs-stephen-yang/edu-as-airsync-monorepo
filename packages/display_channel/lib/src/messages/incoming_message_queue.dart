class IncomingMessageQueue<T> {
  int _nextSequenceNumber = 0;

  final _messages = <int, T>{};

  int get nextSequenceNumber => _nextSequenceNumber;

  void addMessage(int sequenceNumber, T message) {
    if (sequenceNumber < _nextSequenceNumber) {
      // drop duplicate message
      return;
    }

    _messages[sequenceNumber] = message;
  }

  T? popNextMessage() {
    if (_messages.isEmpty) {
      return null;
    }

    final nextMessage = _messages[_nextSequenceNumber];
    if (nextMessage == null) {
      return null;
    }

    _messages.remove(_nextSequenceNumber);
    _nextSequenceNumber += 1;

    return nextMessage;
  }
}
