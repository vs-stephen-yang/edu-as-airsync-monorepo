abstract class GroupListItem {
  String deviceName();

  String displayCode();

  String invitedState();

  String ip();

  String id();

  String serviceName();

  bool unsupportedMulticast();

  String ver();
}

class GroupBean extends GroupListItem {
  String? _name;
  String? _type;
  int? _port;
  String? _host;
  Attributes? _attributes;

  GroupBean(
      {String? name,
      String? type,
      int? port,
      String? host,
      Attributes? attributes})
      : _attributes = attributes,
        _host = host,
        _port = port,
        _type = type,
        _name = name;

  GroupBean.fromJson(Map<String, dynamic> json) {
    _name = json['service.name'];
    _type = json['service.type'];
    _port = json['service.port'];
    _host = json['service.host'];
    _attributes = json['service.attributes'] != null
        ? Attributes.fromJson(json['service.attributes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = _name;
    data['type'] = _type;
    data['port'] = _port;
    data['host'] = _host;
    if (_attributes != null) {
      data['attributes'] = _attributes!.toJson();
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
  String deviceName() => _attributes?.fn ?? '';

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
