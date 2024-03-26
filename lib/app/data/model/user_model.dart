class User {
  String? id;
  String? nama;
  String? kodeCabang;

  User({this.id, this.nama, this.kodeCabang});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    kodeCabang = json['kode_cabang'];
  }
}
