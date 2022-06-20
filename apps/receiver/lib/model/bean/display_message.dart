class DisplayMessage {
  String? messageFor;
  String? userId;
  String? action;
  dynamic status;
  dynamic extra;
  String? direction;
  String? messageId;
  String? nextId;

  DisplayMessage({
    this.messageFor,
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
    userId = json['userid'];
    action = json['action'];
    status = json['status'];
    extra = json['extra'];
    direction = json['direction'];
    messageId = json['messageId'];
    nextId = json['nextId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageFor'] = messageFor;
    data['userId'] = userId;
    data['action'] = action;
    data['status'] = status;
    data['extra'] = extra;
    data['direction'] = direction;
    data['messageId'] = messageId;
    data['nextId'] = nextId;

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    data['status'] = status;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['setClientId'] = setClientId;
    data['setAllowedPeer'] = setAllowedPeer;
    data['presenter'] = presenter;
    data['moderator'] = moderator;
    data['endTime'] = endTime;
    data['moderatedSessionId'] = moderatedSessionId;
    data['checkPoints'] = checkPoints;
    data['durationRemaining'] = durationRemaining;
    data['code'] = code;
    data['delegate'] = delegate;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['remark'] = remark;
    data['status'] = status;
    data['extra'] = extra;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['remark'] = remark;
    data['status'] = status;
    return data;
  }
}
