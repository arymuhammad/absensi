class Cabang {
  String? kodeCabang;
  String? namaCabang;
  String? lat;
  String? long;

  Cabang({this.kodeCabang, this.namaCabang, this.lat, this.long});

  Cabang.fromJson(Map<String, dynamic> json) {
    kodeCabang = json['kode_cabang'];
    namaCabang = json['nama_cabang'];
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kode_cabang'] = kodeCabang;
    data['nama_cabang'] = namaCabang;
    data['lat'] = lat;
    data['long'] = long;
    return data;
  }
}