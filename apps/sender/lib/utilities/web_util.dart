import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool isBigThan768(context) => MediaQuery.of(context).size.width >= 768;

bool isBigThan1024(context) => MediaQuery.of(context).size.width >= 1024;

bool isBigThan1280(context) => MediaQuery.of(context).size.width >= 1280;

bool isBigThan1536(context) => MediaQuery.of(context).size.width >= 1536;

bool isBigThan1920(context) => MediaQuery.of(context).size.width >= 1920;

Future<Map<String, List<String>>> fetchWebTransportCertificateHashes() async {
  try {
    String data = await rootBundle.loadString("assets/webtransport_cert_hashes.json");
    Map<String, dynamic> jsonData = json.decode(data);

    final certMap = filterValidHashes(jsonData['certs'], DateTime.now().toUtc());
    return certMap;
  } catch (e) {
    throw Exception('Asset not found: $e');
  }
}

Map<String, List<String>> filterValidHashes(List<dynamic> certs, DateTime today) {
  final validCerts = certs.where((cert) {
    DateTime certDate = DateTime.parse(cert['date']);
    return today.isAfter(certDate) && today.isBefore(certDate.add(const Duration(days: 14)));
  }).toList();

  final List<String> validHashes = validCerts
      .map<String>((cert) => cert['hash'].trim().replaceAll(' ', ''))
      .toList();
  final List<String> validDates = validCerts
      .map<String>((cert) => cert['date'])
      .toList();

  return {
    'hashes': validHashes,
    'dates': validDates,
  };
}