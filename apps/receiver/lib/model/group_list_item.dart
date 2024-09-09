class GroupListItem {
  final String name;
  final String displayCode;
  final String invitedState;
  final String id;

  GroupListItem({
    required this.name,
    required this.displayCode,
    required this.invitedState,
    required this.id,
  });

  factory GroupListItem.fromJson(Map<String, dynamic> json) {
    return GroupListItem(
      name: json['name'],
      displayCode: json['displayCode'],
      invitedState: json['invitedState'],
      id: json['id'],
    );
  }
}
