import 'dart:async';

import 'package:rxdart/rxdart.dart';

// STEP1:  Stream setup
class StreamResponse {
  final _response = BehaviorSubject<Map>();
  final _errorResponse = BehaviorSubject<Exception>();

  void addResponseMessage(message) {
    _response.add(message);
  }

  void addErrorResponseMessage(message) {
    _response.add(message);
  }

  Stream<Map> get getResponse => _response.stream;

  Stream<Exception> get getErrorResponse => _errorResponse.stream;

  void dispose() {
    _response.close();
    _errorResponse.close();
  }
}

//STEP2: Add this function in main function in main.dart file and add incoming data to the stream
