/// A class that maintains a list with a fixed maximum size.
/// When a new element is added and the list exceeds the maximum size,
/// the oldest element is removed to ensure the list always stays within the specified limit.
class BoundedList<T> {
  final int maxSize;
  final List<T> _list = [];

  BoundedList(this.maxSize);

  void add(T element) {
    if (_list.length >= maxSize) {
      _list.removeAt(0); // Remove the oldest element
    }
    _list.add(element);
  }

  List<T> get elements => List.unmodifiable(_list);

  @override
  String toString() {
    return _list.toString();
  }

  void clear() {
    _list.clear();
  }
}
