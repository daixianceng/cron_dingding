class TaskModel {
  String id;
  String name;
  String schedule;
  bool active;

  TaskModel.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'],
        schedule = json['schedule'],
        active = json['active'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'schedule': schedule,
        'active': active,
      };
}
