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
  late String? isRnd;

  Visit({
    this.id,
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
    this.deviceInfo2,
    this.isRnd,
  });

  Visit.fromJson(Map<String, dynamic> json) {
    id = json['id_user'];
    nama = json['nama'];
    namaCabang = json['nama_cabang'] ?? json['visit_in'];
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
    isRnd = json['is_rnd'];
  }

  Map<String, Object?> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_user'] = id;
    data['nama'] = nama;
    // data['nama_cabang'] = namaCabang;
    data['tgl_visit'] = tglVisit;
    data['visit_in'] = visitIn;
    data['jam_in'] = jamIn;
    data['visit_out'] = visitOut;
    data['jam_out'] = jamOut;
    data['foto_in'] = fotoIn;
    data['lat_in'] = latIn;
    data['long_in'] = longIn;
    data['foto_out'] = fotoOut;
    data['lat_out'] = latOut;
    data['long_out'] = longOut;
    data['device_info'] = deviceInfo;
    data['device_info2'] = deviceInfo2;
    data['is_rnd'] = isRnd;
    return data;
  }

  Visit.fromMap(Map<String, dynamic> map) {
    id = map['id_user'];
    nama = map['nama'];
    namaCabang = map['nama_cabang'] ?? map['visit_in'];
    tglVisit = map['tgl_visit'];
    visitIn = map['visit_in'];
    jamIn = map['jam_in'];
    visitOut = map['visit_out'];
    jamOut = map['jam_out'];
    fotoIn = map['foto_in'];
    latIn = map['lat_in'];
    longIn = map['long_in'];
    fotoOut = map['foto_out'];
    latOut = map['lat_out'];
    longOut = map['long_out'];
    deviceInfo = map['device_info'];
    deviceInfo2 = map['device_info2'];
    isRnd = map['is_rnd'];
  }
}
