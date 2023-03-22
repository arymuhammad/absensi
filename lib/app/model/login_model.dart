class Login {
  bool? success;
  Data? data;

  Login({this.success, this.data});

  Login.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? nama;
  String? username;
  String? password;
  String? kodeCabang;
  String? namaCabang;
  String? lat;
  String? long;
  String? foto;
  String? noTelp;
  String? level;
  String? levelUser;

  Data({
    this.id,
    this.nama,
    this.username,
    this.password,
    this.kodeCabang,
    this.namaCabang,
    this.lat,
    this.long,
    this.foto,
    this.noTelp,
    this.level,
    this.levelUser,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    username = json['username'];
    password = json['password'];
    kodeCabang = json['kode_cabang'];
    namaCabang = json['nama_cabang'];
    lat = json['lat'];
    long = json['long'];
    foto = json['foto'];
    noTelp = json['no_telp'];
    level = json['level'];
    levelUser = json['level_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama'] = nama;
    data['username'] = username;
    data['password'] = password;
    data['kode_cabang'] = kodeCabang;
    data['nama_cabang'] = namaCabang;
    data['foto'] = foto;
    return data;
  }
}
