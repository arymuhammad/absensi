class CekAbsen {
  String? total;
  String? tanggalMasuk;
  String? tanggalPulang;
  String? idShift;

  CekAbsen({this.total, this.tanggalMasuk, this.tanggalPulang});
  CekAbsen.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    tanggalMasuk = json['tanggal_masuk'];
    tanggalPulang = json['tanggal_pulang'];
    idShift = json['id_shift'];
  }
}
