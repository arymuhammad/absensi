class CekAbsen {
  String? total;

  CekAbsen({this.total});
  CekAbsen.fromJson(Map<String, dynamic> json) {
    total = json['total'];
  }
}
