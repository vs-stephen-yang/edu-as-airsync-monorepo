class Moderator {
  String? id;
  String? name;
  int? presenters;
  String? status;
  Map<String, dynamic>? extra;

  Moderator(this.id, this.name, this.presenters, this.status, this.extra);

  Moderator.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        presenters = json['presenters'],
        status = json['status'],
        extra = json['extra'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'presenters': presenters,
    'status': status,
    'extra': extra,
  };

}