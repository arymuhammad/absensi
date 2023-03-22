class Absen {
  String? idUser;
  String? tanggal;
  String? nama;
  String? idShift;
  String? jamMasuk;
  String? jamPulang;
  String? jamAbsenMasuk;
  String? jamAbsenPulang;
  String? fotoMasuk;
  String? fotoPulang;
  String? latMasuk;
  String? longMasuk;
  String? latPulang;
  String? longPulang;

  Absen(
      {this.idUser,
      this.tanggal,
      this.nama,
      this.idShift,
      this.jamMasuk,
      this.jamPulang,
      this.jamAbsenMasuk,
      this.jamAbsenPulang,
      this.fotoMasuk,
      this.fotoPulang,
      this.latMasuk,
      this.longMasuk,
      this.latPulang,
      this.longPulang});

  Absen.fromJson(Map<String, dynamic> json) {
    idUser = json['id_user'];
    tanggal = json['tanggal'];
    nama = json['nama'];
    idShift = json['id_shift'];
    jamMasuk = json['jam_masuk'];
    jamPulang = json['jam_pulang'];
    jamAbsenMasuk = json['jam_absen_masuk'];
    jamAbsenPulang = json['jam_absen_pulang'];
    fotoMasuk = json['foto_masuk'];
    fotoPulang = json['foto_pulang'];
    latMasuk = json['lat_masuk'];
    longMasuk = json['long_masuk'];
    latPulang = json['lat_pulang'];
    longPulang = json['long_pulang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_user'] = idUser;
    data['tanggal'] = tanggal;
    data['nama'] = nama;
    data['id_shift'] = idShift;
    data['jam_masuk'] = jamMasuk;
    data['jam_pulang'] = jamPulang;
    data['jam_absen_masuk'] = jamAbsenMasuk;
    data['jam_absen_pulang'] = jamAbsenPulang;
    data['foto_masuk'] = fotoMasuk;
    data['foto_pulang'] = fotoPulang;
    data['lat_masuk'] = latMasuk;
    data['long_masuk'] = longMasuk;
    data['lat_pulang'] = latPulang;
    data['long_pulang'] = longPulang;
    return data;
  }
}