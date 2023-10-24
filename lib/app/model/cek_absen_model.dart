class CekAbsen {
  String? total;
  String? tanggal;

  CekAbsen({this.total, this.tanggal});
  CekAbsen.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    tanggal = json['tanggal'];
  }
}
