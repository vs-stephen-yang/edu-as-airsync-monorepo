class Presenter {
  String? id;
  String? name = '';
  String? remark = '';
  String? status = '';
  Map<String, dynamic>? extra = {};

  Presenter({this.id, this.name, this.remark, this.status, this.extra});

  Presenter.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        remark = json['remark'],
        status = json['status'],
        extra = json['extra'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'remark': remark,
    'status': status,
    'extra': extra,
  };

}