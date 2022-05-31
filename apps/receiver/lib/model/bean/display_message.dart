class DisplayMessage {
  String? messageFor;
  String? userId;
  String? action;
  dynamic status;
  dynamic extra;
  String? direction;
  String? messageId;
  String? nextId;

  DisplayMessage(
      {this.messageFor,
        this.userId,
        this.action,
        this.status,
        this.extra,
        this.direction,
        this.messageId,
        this.nextId,
      });

  DisplayMessage.fromJson(Map<String, dynamic> json) {
    messageFor = json['messageFor'];
    userId = json['userId'];
    action = json['action'];
    status = json['status'];
    extra = json['extra'];
    direction = json['direction'];
    messageId = json['messageId'];
    nextId = json['nextId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageFor'] = this.messageFor;
    data['userId'] = this.userId;
    data['action'] = this.action;
    data['status'] = this.status;
    data['extra'] = this.extra;
    data['direction'] = this.direction;
    data['messageId'] = this.messageId;
    data['nextId'] = this.nextId;

    return data;
  }
}

class Status {
  String? action;
  String? status;

  Status({this.action, this.status});

  Status.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['action'] = this.action;
    data['status'] = this.status;
    return data;
  }
}

class Extra {
  String? setClientId;
  String? setAllowedPeer;
  dynamic presenter;
  dynamic moderator;
  int? endTime = 0;
  String? moderatedSessionId;
  List<dynamic>? checkPoints;
  int? durationRemaining = 0;
  bool? code = false;
  bool? delegate = false;

  Extra({
    this.setClientId,
    this.setAllowedPeer,
    this.presenter,
    this.moderator,
    this.moderatedSessionId,
    this.checkPoints,
  });

  Extra.fromJson(Map<String, dynamic> json) {
    setClientId = json['setClientId'];
    setAllowedPeer = json['setAllowedPeer'];
    presenter = json['presenter'];
    moderator = json['moderator'];
    endTime = json['endTime'];
    moderatedSessionId = json['moderatedSessionId'];
    checkPoints = json['checkPoints'];
    durationRemaining = json['durationRemaining'];
    code = json['code'];
    delegate = json['delegate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setClientId'] = this.setClientId;
    data['setAllowedPeer'] = this.setAllowedPeer;
    data['presenter'] = this.presenter;
    data['moderator'] = this.moderator;
    data['endTime'] = this.endTime;
    data['moderatedSessionId'] = this.moderatedSessionId;
    data['checkPoints'] = this.checkPoints;
    data['durationRemaining'] = this.durationRemaining;
    data['code'] = this.code;
    data['delegate'] = this.delegate;
    return data;
  }
}

class Presenter {
  String? id;
  String? name;
  String? remark;
  String? status;
  dynamic extra;

  Presenter({this.id, this.name, this.remark, this.status, this.extra});

  Presenter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    remark = json['remark'];
    status = json['status'];
    extra = json['extra'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['remark'] = this.remark;
    data['status'] = this.status;
    data['extra'] = this.extra;
    return data;
  }
}

class Moderator {
  String? id;
  String? name;
  String? remark;
  String? status;

  Moderator({this.id, this.name, this.remark, this.status});

  Moderator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    remark = json['remark'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['remark'] = this.remark;
    data['status'] = this.status;
    return data;
  }
}

