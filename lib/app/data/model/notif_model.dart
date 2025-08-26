class NotifModel {
  late int? totalRequest;
  late int? totalNotif;

  NotifModel({this.totalRequest, this.totalNotif});
  NotifModel.fromJson(Map<String, dynamic> json) {
    totalRequest = int.tryParse(json['total_request']?.toString() ?? '0') ?? 0;
    totalNotif = int.tryParse(json['total']?.toString() ?? '0') ?? 0;
  }
}
