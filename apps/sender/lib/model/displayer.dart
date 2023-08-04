class Displayer {
  String? code;
  Map<String, dynamic>? property = {};
  String? enrolledAt = '';
  String? updatedAt = '';
  String? entityId = '';
  String? sort = '';
  String? token = '';

  Displayer({this.code, this.property, this.enrolledAt, this.updatedAt, this.entityId, this.sort, this.token});

  Displayer.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        property = json['property'],
        enrolledAt = json['enrolledAt'],
        updatedAt = json['updatedAt'],
        entityId = json['entityId'],
        sort = json['sort'],
        token = json['token'];

  Map<String, dynamic> toJson() => {
    'code': code,
    'property': property,
    'enrolledAt': enrolledAt,
    'updatedAt': updatedAt,
    'entityId': entityId,
    'sort': sort,
    'token': token,
  };

}