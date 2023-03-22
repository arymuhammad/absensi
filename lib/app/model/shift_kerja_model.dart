class ShiftKerja {
  String? id;
  String? namaShift;
  String? jamMasuk;
  String? jamPulang;

  ShiftKerja({this.id, this.namaShift, this.jamMasuk, this.jamPulang});
  ShiftKerja.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaShift = json['nama_shift'];
    jamMasuk = json['jam_masuk'];
    jamPulang = json['jam_pulang'];
  }
}
