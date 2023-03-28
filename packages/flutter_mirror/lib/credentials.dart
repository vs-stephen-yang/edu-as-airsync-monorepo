import 'dart:typed_data';

class Credentials {
  final int year;
  final int month;
  final int day;

  // device certificate in DER format
  final Uint8List deviceCertDer;
  // ICA (Intermediate Certificate Authority) certificate in DER format
  final Uint8List icaCertDer;

  // TLS certificate in DER format
  final Uint8List tlsCertDer;
  // TLS private key in DER format
  final Uint8List tlsKeyDer;

  final Uint8List signature;

  const Credentials(
    this.year,
    this.month,
    this.day,
    this.deviceCertDer,
    this.icaCertDer,
    this.tlsCertDer,
    this.tlsKeyDer,
    this.signature,
  );
}
