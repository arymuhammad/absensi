class LeaveModel {
  String? id;
  String? name;
  String? duration;

  LeaveModel({this.id, this.name, this.duration});

  LeaveModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    duration = json['duration'];
  }
}
