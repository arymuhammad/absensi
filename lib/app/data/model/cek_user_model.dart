class CekUser {
  String? id;
  String? username;
  String? password;
  String? nama;
  String? notelp;
  String? kodeCabang;
  String? level;
  String? foto;

  CekUser(
      {this.id,
      this.username,
      this.password,
      this.nama,
      this.notelp,
      this.kodeCabang,
      this.level,
      this.foto});
  CekUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    password = json['password'];
    nama = json['nama'];
    notelp = json['no_telp'];
    kodeCabang = json['kode_cabang'];
    level = json['level'];
    foto = json['foto'];
  }
}
