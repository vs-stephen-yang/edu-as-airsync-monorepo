import 'dart:async';
import 'dart:convert';
import 'package:display_channel/display_channel.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:display_flutter/utility/webrtc_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:ntp/ntp.dart';

class TestResult {
  final bool success;
  final String? error;

  TestResult({
    required this.success,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
    };
  }
}

class NtpTestResult extends TestResult {
  final String offset;

  NtpTestResult({
    required this.offset,
    required super.success,
    super.error,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['offset'] = offset;
    return json;
  }
}

class PortTestResult extends TestResult {
  final int port;

  PortTestResult({
    required this.port,
    required super.success,
    super.error,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['port'] = port;
    return json;
  }
}

enum TunnelStatusType { register, connect }

class TunnelResult extends TestResult {
  final String status;

  TunnelResult({
    required this.status,
    required super.success,
    super.error,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['status'] = status;
    return json;
  }
}

class NetworkDiagnostic {
  final DiagnosticResults _results = DiagnosticResults();

  NetworkDiagnostic();

  // Run all diagnostic tests
  Future<DiagnosticResults> runAllTests(List<RtcIceServer> iceServers) async {
    // Run tests in parallel for efficiency
    await Future.wait([
      _testWebRTCCandidates(iceServers),
      _testNtpOffset(),
    ]);

    // TODO: replace
    _results.logResult();
    return _results;
  }

  Future<void> _testNtpOffset() async {
    try {
      DateTime startDate = DateTime.now().toLocal();
      int offset = await NTP.getNtpOffset(localTime: startDate);
      _results.ntpOffset = NtpTestResult(offset: '$offset ms', success: true);
    } catch (e) {
      _results.ntpOffset =
          NtpTestResult(offset: '', success: false, error: e.toString());
    }
  }

  // Test WebRTC candidate gathering including STUN and TURN
  Future<void> _testWebRTCCandidates(List<RtcIceServer> iceServers) async {
    final configuration = WebRTCUtil.createPcConfiguration(iceServers);

    RTCPeerConnection? peerConnection;
    try {
      peerConnection = await createPeerConnection(configuration);

      // Track candidates by type
      List<RTCIceCandidate> udpCandidates = [];
      List<RTCIceCandidate> tcpCandidates = [];
      List<RTCIceCandidate> stunCandidates = []; // srflx candidates
      List<RTCIceCandidate> turnCandidates = []; // relay candidates

      Completer<void> candidateGatheringCompleter = Completer();

      peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
        log.info('[Network Diagnostic] ICE Candidate: ${candidate.toMap()}');
        final candidateString = candidate.candidate ?? '';

        // Categorize by transport protocol
        if (candidateString.contains('udp')) {
          udpCandidates.add(candidate);
        } else if (candidateString.contains('tcp')) {
          tcpCandidates.add(candidate);
        }

        // Categorize by candidate type
        if (candidateString.contains('srflx')) {
          stunCandidates.add(candidate); // Server reflexive - from STUN
        } else if (candidateString.contains('relay')) {
          turnCandidates.add(candidate); // Relay - from TURN
        }
      };

      peerConnection.onIceGatheringState = (RTCIceGatheringState state) async {
        log.info('[Network Diagnostic] ICE Gathering State: $state');
        if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
          log.info('[Network Diagnostic] ICE Gathering Complete');
        }
      };

      await peerConnection.createDataChannel(
          'diagnosticChannel', RTCDataChannelInit());
      RTCSessionDescription localDesc = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(localDesc);

      // Set timeout for candidate gathering
      Timer(const Duration(seconds: 10), () {
        if (!candidateGatheringCompleter.isCompleted) {
          candidateGatheringCompleter.complete();
        }
      });

      // Wait for candidate gathering
      await candidateGatheringCompleter.future;

      // Update transport protocol results
      _results.udpCandidateTest = TestResult(
        success: udpCandidates.isNotEmpty,
        error: udpCandidates.isEmpty ? 'No UDP candidates gathered' : null,
      );

      _results.tcpCandidateTest = TestResult(
        success: tcpCandidates.isNotEmpty,
        error: tcpCandidates.isEmpty ? 'No TCP candidates gathered' : null,
      );

      // Update STUN and TURN results
      _results.stunServerTest = TestResult(
        success: stunCandidates.isNotEmpty,
        error: stunCandidates.isEmpty
            ? 'No STUN server reflexive candidates gathered'
            : null,
      );

      _results.turnServerTest = TestResult(
        success: turnCandidates.isNotEmpty,
        error:
            turnCandidates.isEmpty ? 'No TURN relay candidates gathered' : null,
      );
    } catch (e) {
      // In case of error, set all candidate tests to failed
      final errorMsg = e.toString();
      _results.udpCandidateTest = TestResult(success: false, error: errorMsg);
      _results.tcpCandidateTest = TestResult(success: false, error: errorMsg);
      _results.stunServerTest = TestResult(success: false, error: errorMsg);
      _results.turnServerTest = TestResult(success: false, error: errorMsg);
    } finally {
      await peerConnection?.close();
    }
  }

  importPortTestResult(int port, bool success, String? error) {
    _results.portTests
        .add(PortTestResult(port: port, success: success, error: error));

    // TODO: replace
    _results.logResult();
  }

  setTunnelResult(TunnelStatusType type, bool success, String status) {
    if (type == TunnelStatusType.register) {
      _results.tunnelRegisterTest =
          TunnelResult(status: status, success: success);
    } else {
      _results.tunnelConnectionTest =
          TunnelResult(status: status, success: success);
    }

    // TODO: replace
    _results.logResult();
  }

  reportTunnelConnectResult(bool success, String status) {
    setTunnelResult(TunnelStatusType.connect, success, status);
  }

  reportWebTransportCertDate(String date) {
    _results.webTransportCertDate = date;

    // TODO: replace
    _results.logResult();
  }
}

// Models for diagnostic results and configuration
class DiagnosticResults {
  List<PortTestResult> portTests = [];
  String? webTransportCertDate;
  NtpTestResult? ntpOffset;
  TunnelResult? tunnelRegisterTest;
  TunnelResult? tunnelConnectionTest;
  TestResult? udpCandidateTest;
  TestResult? tcpCandidateTest;
  TestResult? stunServerTest;
  TestResult? turnServerTest;

  Map<String, dynamic> toJson() {
    return {
      'portTests': portTests.map((test) => test.toJson()).toList(),
      'webTransportCertDate': webTransportCertDate,
      'ntpOffset': ntpOffset,
      'tunnelRegisterTest': tunnelRegisterTest?.toJson(),
      'tunnelConnectionTest': tunnelConnectionTest?.toJson(),
      'udpCandidateTest': udpCandidateTest?.toJson(),
      'tcpCandidateTest': tcpCandidateTest?.toJson(),
      'stunServerTest': stunServerTest?.toJson(),
      'turnServerTest': turnServerTest?.toJson(),
    };
  }

  logResult() {
    String jsonString = jsonEncode(toJson());
    log.info('[Network Diagnostic] Result: $jsonString');
  }
}
