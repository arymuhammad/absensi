class Users {
  String? id;
  String? nama;
  String? nik;
  String? notelp;
  String? foto;
  String? cabang;
  String? levelUser;

  Users(
      {this.id,
      this.nama,
      this.nik,
      this.notelp,
      this.foto,
      this.cabang,
      this.levelUser});
  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    nik = json['nik'];
    notelp = json['no_telp'];
    foto = json['foto'];
    cabang = json['nama_cabang'];
    levelUser = json['level_user'];
  }
}
