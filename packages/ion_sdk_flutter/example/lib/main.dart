import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:uuid/uuid.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ion.Client _client;

  @override
  void initState() {
    super.initState();
  }

  publishStream() async {
    var signal = ion.JsonRPCSignal("ws://172.21.6.32:7000/ws");
    String uuid = Uuid().v4();
    String room = "ion";
    _client = await ion.Client.create(sid: room, uid: uuid, signal: signal);

    var localStream = await ion.LocalStream.getDisplayMedia(
        constraints: ion.Constraints.defaults..simulcast = false);
    await _client.publish(localStream);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('ION example'),
          ),
          body: Center(
          child: ElevatedButton(
            child: Text('Publish Stream'),
            // call publishStream
            onPressed: publishStream,
            ),
          ),
      )
    );
  }
}
