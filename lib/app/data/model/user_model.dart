class User {
  String? id;
  String? username;
  String? password;
  String? nama;
  String? noTelp;
  String? kodeCabang;
  String? level;
  String? namaLevel;
  String? foto;

  User({this.id, this.username, this.password, this.nama, this.noTelp, this.kodeCabang, this.level, this.foto});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    password = json['password'];
    nama = json['nama'];
    noTelp = json['no_telp'].toString();
    kodeCabang = json['kode_cabang'];
    level = json['level'].toString();
    namaLevel = json['nama_level'].toString();
    foto = json['foto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['password'] = password;
    data['nama'] = nama;
    data['no_telp'] = noTelp;
    data['kode_cabang'] = kodeCabang;
    data['level'] = level;
    data['nama_level'] = namaLevel;
    data['foto'] = foto;
    return data;
  }
}
