abstract class GroupListItem {
  String deviceName();

  String displayCode();

  String invitedState();

  String ip();

  String id();

  String serviceName();

  bool unsupportedMulticast();

  String ver();

  bool favorite();

  bool viaIp();

  bool ipNotFind();

  int favoriteTimestamp();

  bool offline();

  Map<String, dynamic> toJson();
}

class GroupBean extends GroupListItem {
  String? _name;
  String? _type;
  int? _port;
  String? _host;
  Attributes? _attributes;
  bool? _viaIp;
  bool? _favorite;
  bool? _notFind;
  int? _favoriteTimestamp;
  bool? _offline;

  GroupBean(
      {String? name,
      String? type,
      int? port,
      String? host,
      Attributes? attributes,
      bool viaIp = false,
      bool favorite = false,
      bool notFind = false,
      int? favoriteTimestamp,
      bool offline = false})
      : _attributes = attributes,
        _host = host,
        _port = port,
        _type = type,
        _name = name,
        _viaIp = viaIp,
        _favorite = favorite,
        _notFind = notFind,
        _offline = offline,
        _favoriteTimestamp =
            favoriteTimestamp ?? DateTime.now().millisecondsSinceEpoch;

  GroupBean.fromJson(Map<String, dynamic> json,
      {bool? viaIp, bool? favorite, bool? offline}) {
    _name = json['service.name'];
    _type = json['service.type'];
    _port = json['service.port'];
    _host = json['service.host'];
    // 如果 JSON 中的值為 null，使用預設值 false
    _viaIp = json['service.viaIp'] ?? false;
    _favorite = json['service.favorite'] ?? false;
    _notFind = json['service.notFind'] ?? false;
    _offline = json['service.offline'] ?? false;
    _favoriteTimestamp = json['service.favoriteTimestamp'] ??
        DateTime.now().millisecondsSinceEpoch;
    if (viaIp != null) {
      _viaIp = viaIp;
    }
    if (favorite != null) {
      _favorite = favorite;
    }
    if (offline != null) {
      _offline = offline;
    }
    _attributes = json['service.attributes'] != null
        ? Attributes.fromJson(json['service.attributes'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service.name'] = _name;
    data['service.type'] = _type;
    data['service.port'] = _port;
    data['service.host'] = _host;
    data['service.viaIp'] = _viaIp;
    data['service.favorite'] = _favorite;
    data['service.favoriteTimestamp'] = _favoriteTimestamp;
    data['service.notFind'] = _notFind;
    data['service.offline'] = _offline;
    // _timestamp不存
    if (_attributes != null) {
      data['service.attributes'] = _attributes!.toJson();
    }
    return data;
  }

  @override
  String displayCode() => _attributes?.dc ?? '';

  @override
  String id() => _attributes?.id ?? '';

  @override
  String invitedState() => _attributes?.igo ?? '0';

  @override
  String deviceName() => _viaIp == true ? ip() : _attributes?.fn ?? '';

  @override
  String ip() => _attributes?.ip ?? '';

  @override
  String serviceName() => _name ?? '';

  @override
  bool unsupportedMulticast() {
    return _attributes?.mc != '1';
  }

  @override
  String ver() {
    return _attributes?.ver ?? '';
  }

  @override
  bool favorite() {
    return _favorite ?? false;
  }

  @override
  bool viaIp() {
    return _viaIp ?? false;
  }

  @override
  bool ipNotFind() {
    return _notFind ?? false;
  }

  @override
  bool offline() {
    return _offline ?? false;
  }

  @override
  int favoriteTimestamp() {
    return _favoriteTimestamp ?? DateTime.now().millisecondsSinceEpoch;
  }
}

class Attributes {
  String? igo;
  String? ver;
  String? ip;
  String? fn;
  String? dc;
  String? id;
  String? mc; // multicast

  Attributes({this.igo, this.ver, this.ip, this.fn, this.dc, this.id, this.mc});

  Attributes.fromJson(Map<String, dynamic> json) {
    igo = json['igo'];
    ver = json['ver'];
    ip = json['ip'];
    fn = json['fn'];
    dc = json['dc'];
    id = json['id'];
    mc = json['mc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['igo'] = igo;
    data['ver'] = ver;
    data['ip'] = ip;
    data['fn'] = fn;
    data['dc'] = dc;
    data['id'] = id;
    data['mc'] = mc;
    return data;
  }
}
