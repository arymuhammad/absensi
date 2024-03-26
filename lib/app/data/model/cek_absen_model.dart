class CekAbsen {
  String? total;
  String? tanggalMasuk;
  String? tanggalPulang;

  CekAbsen({this.total, this.tanggalMasuk, this.tanggalPulang});
  CekAbsen.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    tanggalMasuk = json['tanggal_masuk'];
    tanggalPulang = json['tanggal_pulang'];
  }
}
