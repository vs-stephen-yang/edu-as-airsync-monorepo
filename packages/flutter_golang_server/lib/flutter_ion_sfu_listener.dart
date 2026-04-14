// ignore_for_file: constant_identifier_names

enum IceConnectionState {
  ICEConnectionStateNew,

  ICEConnectionStateChecking,

  ICEConnectionStateConnected,

  ICEConnectionStateCompleted,

  ICEConnectionStateDisconnected,

  ICEConnectionStateFailed,

  ICEConnectionStateClosed,
}

abstract class FlutterIonSfuListener {
  void onSignalMessage(int channelId, String message);
  void onError(String error, String msg);
  void onIceConnectionState(int channelId, IceConnectionState state);
}
