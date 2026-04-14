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
  String? windowState;
  String? presentationState;

  Extra({
    this.uiState,
    this.windowState,
    this.presentationState,
  });

  Extra.fromJson(Map<String, dynamic> json) {
    uiState = json['uiState'];
    windowState = json['windowState'];
    presentationState = json['presentationState'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uiState'] = uiState;
    data['windowState'] = windowState;
    data['presentationState'] = presentationState;
    return data;
  }
}
