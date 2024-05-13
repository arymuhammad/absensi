class Level {
  String? id;
  String? namaLevel;
  String? visit;
  String? cekStok;

  Level({this.id, namaLevel, visit, cekStok});

  Level.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaLevel = json['nama'];
    visit = json['visit'];
    cekStok = json['cek_stok'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama'] = namaLevel;
    data['visit'] = visit;
    data['cek_stok'] = cekStok;
    return data;
  }
}