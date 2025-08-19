class NotifModel {
  late int? totalRequest;
  late int? totalNotif;

  NotifModel({this.totalRequest, this.totalNotif});
  NotifModel.fromJson(Map<String, dynamic> json) {
    totalRequest = json['total_request']??0;
    totalNotif = json['total']??0;
  }
}
