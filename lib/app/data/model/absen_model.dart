class Absen {
  String? idUser;
  String? tanggalMasuk;
  String? tanggalPulang;
  String? nama;
  String? namaCabang;
  String? kodeCabang;
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
  String? namaShift;
  String? devInfo;
  String? devInfo2;

  Absen(
      {this.idUser,
      this.tanggalMasuk,
      this.tanggalPulang,
      this.nama,
      this.namaCabang,
      this.kodeCabang,
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
      this.longPulang,
      this.namaShift,
      this.devInfo,
      this.devInfo2,
      });

  Absen.fromJson(Map<String, dynamic> json) {
    idUser = json['id_user'];
    tanggalMasuk = json['tanggal_masuk'];
    tanggalPulang = json['tanggal_pulang'];
    nama = json['nama'];
    namaCabang = json['nama_cabang'];
    kodeCabang = json['kode_cabang'];
    idShift = json['id_shift'].toString();
    jamMasuk = json['jam_masuk'];
    jamPulang = json['jam_pulang'];
    jamAbsenMasuk = json['jam_absen_masuk'];
    jamAbsenPulang = json['jam_absen_pulang'];
    fotoMasuk = json['foto_masuk'];
    fotoPulang = json['foto_pulang'];
    latMasuk = json['lat_masuk'].toString();
    longMasuk = json['long_masuk'].toString();
    latPulang = json['lat_pulang'].toString();
    longPulang = json['long_pulang'].toString();
    namaShift = json['nama_shift'];
    devInfo = json['device_info'];
    devInfo2 = json['device_info2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_user'] = idUser;
    data['tanggal_masuk'] = tanggalMasuk;
    data['tanggal_pulang'] = tanggalPulang;
    data['nama'] = nama;
    // data['nama_cabang'] = namaCabang;
    data['kode_cabang'] = kodeCabang;
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
    // data['nama_shift'] = namaShift;
    data['device_info'] = devInfo;
    data['device_info2'] = devInfo2;
    return data;
  }
}