import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_golang_server/flutter_webtransport.dart';
import 'package:flutter_golang_server/flutter_webtransport_config.dart';
import 'package:flutter_golang_server/flutter_webtransport_listener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements FlutterWebtransportListener {
  String _message = '';
  final _flutterWebtransportPlugin = FlutterWebtransport();

  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    late String message;

    List<String> pemCertificate = [];
    List<String> pemKey = [];

    try {
      final certData = await rootBundle
          .loadString('assets/cert.pem'); // Replace with actual path
      pemCertificate = certData.split('\n');

      final keyData = await rootBundle
          .loadString('assets/key.pem'); // Replace with actual path
      pemKey = keyData.split('\n');

      _flutterWebtransportPlugin.registerListener(this);

      final config = FlutterWebtransportConfig(
          port: 8888, cert: pemCertificate, key: pemKey, allowOrigins: []);

      await _flutterWebtransportPlugin.startWebtransportServer(config);
      message = "Webtransport Server started";
    } on Exception catch (e) {
      message = "Webtransport Server start failed: $e";
    }

    setState(() {
      _message = message;
    });
  }

  Future<void> stopServer() async {
    try {
      await _flutterWebtransportPlugin.stopServer();
      setState(() {
        _message = "Webtransport Server stopped";
      });
    } on Exception catch (e) {
      setState(() {
        _message = "Failed to stop Webtransport Server: $e";
      });
    }
  }

  Future<void> updateCertificate() async {
    List<String> pemCertificate = [];
    List<String> pemKey = [];

    final certData = await rootBundle
        .loadString('assets/cert2.pem'); // Replace with actual path
    pemCertificate = certData.split('\n');

    final keyData = await rootBundle
        .loadString('assets/key.pem'); // Replace with actual path
    pemKey = keyData.split('\n');

    _flutterWebtransportPlugin.registerListener(this);

    final config = FlutterWebtransportConfig(cert: pemCertificate, key: pemKey);
    await _flutterWebtransportPlugin.updateCertificate(config);
    setState(() {
      _message = "Updated Certificate";
    });
  }

  Future<void> sendMessage() async {
    final clientId = _clientIdController.text;
    final message = _messageController.text;

    if (message.isEmpty || clientId.isEmpty) {
      setState(() {
        _message = "Invalid client ID or message";
      });
      return;
    }

    try {
      print("clientId: $clientId, message: $message");
      await _flutterWebtransportPlugin.sendMessage(clientId, message);
      setState(() {
        _message = "Message sent to client $clientId";
      });
    } on Exception catch (e) {
      setState(() {
        _message = "Failed to send message: $e";
      });
    }
  }

  Future<void> closeConn() async {
    final clientId = _clientIdController.text;

    if (clientId.isEmpty) {
      setState(() {
        _message = "Invalid client ID";
      });
      return;
    }

    try {
      await _flutterWebtransportPlugin.closeWebTransportConn(clientId);
      setState(() {
        _message = "Close conn: $clientId";
      });
    } on Exception catch (e) {
      setState(() {
        _message = "Failed to close connection: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: stopServer,
                    child: const Text("Stop Server"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: updateCertificate,
                    child: const Text("Update Certificate"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _clientIdController,
                decoration: const InputDecoration(
                  labelText: "Client ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: sendMessage,
                child: const Text("Send Message"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: closeConn,
                child: const Text("Close Conn"),
              ),
              const SizedBox(height: 20),
              Text(
                _message,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onMessage(String clientId, String message) {
    // Handle incoming messages if needed
    setState(() {
      _message = '$clientId: $message';
    });
  }

  @override
  void onClose(String clientId) {
    setState(() {
      _message = '$clientId: closed';
    });
  }

  @override
  void onConnect(String clientId, String queryStr, String clientIp) {
    // Convert JSON string to Map
    Map<String, dynamic> jsonMap = jsonDecode(queryStr);
    print(jsonMap['clientId']);
    print(jsonMap['displayCode']);
    print(jsonMap['token']);

    setState(() {
      _message = '$clientId: connected, queryStr: $queryStr, clientIp: $clientIp';
    });
  }

  @override
  void onRequestCertificate() {
    print("Call onRequestCertificate on Listener");
  }

  @override
  void onError(String connId, String e) {
    print("Listener on error: connId: $connId, err: $e");
  }
}
