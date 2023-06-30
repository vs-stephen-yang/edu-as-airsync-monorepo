class Message {
  String? messageFor;
  String? action = '';
  String? status = '';
  dynamic extra;

  Message({this.messageFor, this.action, this.status, this.extra});

  Message.fromJson(Map<String, dynamic> json)
      : messageFor = json['messageFor'],
        action = json['action'],
        status = json['status'],
        extra = json['extra'];

  Map<String, dynamic> toJson() => {
    'messageFor': messageFor,
    'action': action,
    'status': status,
    'extra': extra,
  };
}
class Extra {
  // 'start-present'
  dynamic uiState;
  String? presentationState;

  Extra({
    this.uiState,
    this.presentationState,
  });

  Extra.fromJson(Map<String, dynamic> json) {
    uiState = json['uiState'];
    presentationState = json['presentationState'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uiState'] = uiState;
    data['presentationState'] = presentationState;
    return data;
  }
}
