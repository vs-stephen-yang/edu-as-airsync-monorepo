abstract class FlutterWebtransportListener {
  void onMessage(String connId, String message);
  void onClose(String connId);
  void onConnect(String connId, String queryStr, String clientIp);
}
