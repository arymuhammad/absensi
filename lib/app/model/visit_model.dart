class Visit {
  late String? id;
  late String? nama;
  late String? namaCabang;
  late String? tglVisit;
  late String? visitIn;
  late String? jamIn;
  late String? visitOut;
  late String? jamOut;
  late String? fotoIn;
  late String? fotoOut;
  late String? latIn;
  late String? longIn;
  late String? latOut;
  late String? longOut;
  late String? deviceInfo;
  late String? deviceInfo2;

  Visit(
      {this.id,
      this.nama,
      this.namaCabang,
      this.tglVisit,
      this.visitIn,
      this.jamIn,
      this.visitOut,
      this.jamOut,
      this.fotoIn,
      this.fotoOut,
      this.latIn,
      this.longIn,
      this.latOut,
      this.longOut,
      this.deviceInfo,
      this.deviceInfo2});

  Visit.fromJson(Map<String, dynamic> json) {
    id = json['id_user'];
    nama = json['nama'];
    namaCabang = json['nama_cabang'];
    tglVisit = json['tgl_visit'];
    visitIn = json['visit_in'];
    jamIn = json['jam_in'];
    visitOut = json['visit_out'];
    jamOut = json['jam_out'];
    fotoIn = json['foto_in'];
    latIn = json['lat_in'];
    longIn = json['long_in'];
    fotoOut = json['foto_out'];
    latOut = json['lat_out'];
    longOut = json['long_out'];
    deviceInfo = json['device_info'];
    deviceInfo2 = json['device_info2'];
  }
}
