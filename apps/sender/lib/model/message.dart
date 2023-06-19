class Message {
  String? messageFor;
  String? action = '';
  String? status = '';

  Message({this.messageFor, this.action, this.status});

  Message.fromJson(Map<String, dynamic> json)
      : messageFor = json['messageFor'],
        action = json['action'],
        status = json['status'];

  Map<String, dynamic> toJson() => {
    'messageFor': messageFor,
    'action': action,
    'status': status,
  };

}