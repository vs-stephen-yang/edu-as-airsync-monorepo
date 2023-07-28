package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import java.util.Map;

@Keep
public class ServiceInfo {
  public String serviceName;
  public String serviceType;

  public int port;

  public Map<String, String> attributes;
}
