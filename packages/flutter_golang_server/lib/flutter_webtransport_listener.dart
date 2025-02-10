abstract class FlutterWebtransportListener {
  void onMessage(String clientId, String message);
  void onClose(String clientId);
  void onConnect(String clientId, String queryStr);
}
