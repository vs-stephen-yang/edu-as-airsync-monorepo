import 'dart:async';

import 'package:rxdart/rxdart.dart';

// STEP1:  Stream setup
class StreamPeerlist {
  final _response = BehaviorSubject<Map>();

  void addResponseMessage(message) {
    _response.add(message);
  }

  Stream<Map> get getResponse => _response.stream;

  void dispose() {
    _response.close();
  }
}

//STEP2: Add this function in main function in main.dart file and add incoming data to the stream
