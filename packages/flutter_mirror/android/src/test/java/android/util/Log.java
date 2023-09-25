package android.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

// Mock up the Log class during unit test
// https://stackoverflow.com/a/46793567
public class Log {
  final static DateTimeFormatter formatter_ = DateTimeFormatter.ofPattern("HH:mm:ss");

  private static String fmtNow() {
    LocalDateTime now = LocalDateTime.now();
    return String.format("%s.%d", formatter_.format(now), System.currentTimeMillis() % 1000);
  }

  public static int d(String tag, String msg) {
    System.out.println(fmtNow() + " DEBUG " + tag + ": " + msg);
    return 0;
  }

  public static int i(String tag, String msg) {
    System.out.println(fmtNow() + " INFO " + tag + ": " + msg);
    return 0;
  }

  public static int w(String tag, String msg) {
    System.out.println(fmtNow() + " WARN " + tag + ": " + msg);
    return 0;
  }

  public static int e(String tag, String msg) {
    System.out.println(fmtNow() + " ERROR " + tag + ": " + msg);
    return 0;
  }

  // add other methods if required...
}
