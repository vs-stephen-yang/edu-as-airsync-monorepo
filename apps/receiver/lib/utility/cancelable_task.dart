class CancelableTask {
  final Function(CancelableTask self) _task;

  bool _isCanceled = false;
  bool get isCanceled => _isCanceled;

  CancelableTask(this._task);

  void run() {
    _task(this);
  }

  void cancel() {
    _isCanceled = true;
  }
}
