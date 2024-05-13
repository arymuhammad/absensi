class LoginOffline {
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
  String? areaCover;
  String? visit;
  String? cekStok;

  LoginOffline({
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
    this.areaCover,
    this.visit,
    this.cekStok,
  });

   LoginOffline.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    username = json['username'];
    password = json['password'];
    kodeCabang = json['kode_cabang'];
    namaCabang = json['nama_cabang'];
    lat = json['lat'].toString();
    long = json['long'].toString();
    foto = json['foto'];
    noTelp = json['no_telp'].toString();
    level = json['level'].toString();
    levelUser = json['level_user'];
    areaCover = json['area_coverage'].toString();
    visit = json['visit'].toString();
    cekStok = json['cek_stok'].toString();
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
    data['lat'] = lat;
    data['long'] = long;
    data['no_telp'] = noTelp;
    data['level'] = level;
    data['level_user'] = levelUser;
    data['area_coverage'] = areaCover;
    data['visit'] = visit;
    data['cek_stok'] = cekStok;
    return data;
  }
}
