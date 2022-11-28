class DisplayInfo {
  static final DisplayInfo _instance = DisplayInfo._internal();

  //private "Named constructors"
  DisplayInfo._internal();

  // passes the instantiation to the _instance object
  factory DisplayInfo() => _instance;

  bool isBound = false;
  dynamic displayResponse;
  List<DisplayPeer> peerList = <DisplayPeer>[];

  setBindToDisplayInfo(dynamic displayResponse) {
    isBound = true;
    if (displayResponse != null) {
      this.displayResponse = displayResponse;
    }
  }

  removeBindToDisplayInfo() {
    isBound = false;
    peerList.clear();
  }

  clearPeerList() {
    peerList.clear();
  }
}

class DisplayPeer {
  String id = '';
  String presenter = '';
  String status = '';
  dynamic peer;
}
