// an in-memory storage for logging
class LogStorage {
  final int _maxSize;
  final List<String> _logs = [];

  LogStorage(this._maxSize);

  void addLog(String log) {
    if (_logs.length >= _maxSize) {
      _logs.removeAt(0);
    }
    _logs.add(log);
  }

  List<String> getLogs() {
    return List.unmodifiable(_logs);
  }

  void clearLogs() {
    _logs.clear();
  }
}
