abstract class GroupListItem {
  String deviceName();
  String displayCode();
  String invitedState();
  String ip();
  String id();
}

class GroupBean extends GroupListItem{
  String? name;
  String? type;
  int? port;
  String? host;
  Attributes? attributes;

  GroupBean({this.name, this.type, this.port, this.host, this.attributes});

  GroupBean.fromJson(Map<String, dynamic> json) {
    name = json['service.name'];
    type = json['service.type'];
    port = json['service.port'];
    host = json['service.host'];
    attributes = json['service.attributes'] != null
        ? Attributes.fromJson(json['service.attributes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['port'] = port;
    data['host'] = host;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    return data;
  }

  @override
  String displayCode() => attributes?.dc ?? '';

  @override
  String id() => attributes?.id ?? '';

  @override
  String invitedState() => attributes?.igo ?? '0';

  @override
  String deviceName() => attributes?.fn ?? '';

  @override
  String ip() => attributes?.ip ?? '';
}

class Attributes {
  String? igo;
  String? ver;
  String? ip;
  String? fn;
  String? dc;
  String? id;

  Attributes({this.igo, this.ver, this.ip, this.fn, this.dc, this.id});

  Attributes.fromJson(Map<String, dynamic> json) {
    igo = json['igo'];
    ver = json['ver'];
    ip = json['ip'];
    fn = json['fn'];
    dc = json['dc'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['igo'] = igo;
    data['ver'] = ver;
    data['ip'] = ip;
    data['fn'] = fn;
    data['dc'] = dc;
    data['id'] = id;
    return data;
  }
}
