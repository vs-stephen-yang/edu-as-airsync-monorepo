class DisplayMessage {
  String? messageFor;
  String? action;
  String? status;
  dynamic extra;
  String? messageId;
  String? nextId;

  DisplayMessage({
    this.messageFor,
    this.action,
    this.status,
    this.extra,
    this.messageId,
    this.nextId,
  });

  DisplayMessage.fromJson(Map<String, dynamic> json) {
    messageFor = json['messageFor'];
    action = json['action'];
    if (json['status'] is String) {
      status = json['status'];
    }
    extra = json['extra'];
    messageId = json['messageId'];
    nextId = json['nextId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageFor'] = messageFor;
    data['action'] = action;
    data['status'] = status;
    data['extra'] = extra;
    data['messageId'] = messageId;
    data['nextId'] = nextId;
    return data;
  }
}

class Extra {
  dynamic signal;
  dynamic presenter;
  // todo: confirm below item
  dynamic moderator;
  int? endTime = 0;
  String? moderatedSessionId;
  List<dynamic>? checkPoints;
  int? durationRemaining = 0;
  bool? code = false;
  bool? delegate = false;

  Extra({
    this.signal,
    this.presenter,

    this.moderator,
    this.moderatedSessionId,
    this.checkPoints,
  });

  Extra.fromJson(Map<String, dynamic> json) {
    signal = json['signal'];
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
    data['signal'] = signal;
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

class Signal {
  String? token;
  String? peerId;

  Signal({
    this.token,
    this.peerId,
  });

  Signal.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    peerId = json['peerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['peerId'] = peerId;
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
