package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;

import java.util.Map;

@Keep
public class GooglecastCredentials {
  // In UTC time
  public int year;
  public int month;
  public int day;

  public byte[] deviceCertDer;
  public byte[] icaCertDer;
  public byte[] tlsCertDer;
  public byte[] tlsKeyDer;
  public byte[] signature;

  public static GooglecastCredentials fromMap(Map<String, Object> m) {

    GooglecastCredentials cred = new GooglecastCredentials();

    cred.year = (int) m.get("year");
    cred.month = (int) m.get("month");
    cred.day = (int) m.get("day");

    cred.deviceCertDer = (byte[]) m.get("deviceCert");
    cred.icaCertDer = (byte[]) m.get("icaCert");
    cred.tlsCertDer = (byte[]) m.get("tlsCert");
    cred.tlsKeyDer = (byte[]) m.get("tlsKey");
    cred.signature = (byte[]) m.get("signature");

    return cred;
  }
}
