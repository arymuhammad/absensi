class ShiftKerja {
  String? id;
  String? namaShift;
  String? jamMasuk;
  String? jamPulang;

  ShiftKerja({this.id, this.namaShift, this.jamMasuk, this.jamPulang});
  ShiftKerja.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    namaShift = json['nama_shift'];
    jamMasuk = json['jam_masuk'];
    jamPulang = json['jam_pulang'];
  }

  Map<String, Object?> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama_shift'] = namaShift;
    data['jam_masuk'] = jamMasuk;
    data['jam_pulang'] = jamPulang;
    return data;
  }
}
