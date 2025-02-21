import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool isBigThan768(context) => MediaQuery.of(context).size.width >= 768;

bool isBigThan1024(context) => MediaQuery.of(context).size.width >= 1024;

bool isBigThan1280(context) => MediaQuery.of(context).size.width >= 1280;

bool isBigThan1536(context) => MediaQuery.of(context).size.width >= 1536;

bool isBigThan1920(context) => MediaQuery.of(context).size.width >= 1920;



Future<List<String>?> fetchWebTransportCertificateHashes() async {
  try {
    String data = await rootBundle.loadString("assets/webtransport_cert_hashes.json");
    Map<String, dynamic> jsonData = json.decode(data);

    // Get the current UTC date
    final today = DateTime.now().toUtc();

    // List to store selected hash values
    List<String> selectedHashes = [];

    // Process certificates
    for (var cert in jsonData['certs']) {
      String dateStr = cert['date'];
      String hash = cert['hash'];

      // Parse date
      DateTime certDate = DateTime.parse(dateStr);

      // Check if today is within the valid range (certDate to certDate + 14 days)
      if (today.isAfter(certDate) && today.isBefore(certDate.add(Duration(days: 14)))) {
        // Clean up hash formatting and add to the list
        String formattedHash = hash.trim().replaceAll(' ', '');
        selectedHashes.add(formattedHash);
      }
    }

    return selectedHashes;
  } catch (e) {
    throw Exception('asset not found: $e');
  }
}
