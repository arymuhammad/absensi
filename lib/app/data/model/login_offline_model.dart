class LoginOffline {
  String? id;
  String? nama;
  String? username;
  String? password;
  String? kodeCabang;
  String? namaCabang;
  String? nik;
  String? lat;
  String? long;
  String? foto;
  String? noTelp;
  String? level;
  String? levelUser;
  String? areaCover;
  String? visit;
  String? cekStok;
  String? idRegion;
  String? leaveBalance;
  String? createdAt;
  String? parentId;
  String? namaParent;

  LoginOffline({
    this.id,
    this.nama,
    this.username,
    this.password,
    this.kodeCabang,
    this.namaCabang,
    this.nik,
    this.lat,
    this.long,
    this.foto,
    this.noTelp,
    this.level,
    this.levelUser,
    this.areaCover,
    this.visit,
    this.cekStok,
    this.idRegion,
    this.leaveBalance,
    this.createdAt,
    this.parentId,
    this.namaParent,
  });

   LoginOffline.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    username = json['username'];
    password = json['password'];
    kodeCabang = json['kode_cabang'];
    namaCabang = json['nama_cabang'];
    nik = json['nik'].toString();
    lat = json['lat'].toString();
    long = json['long'].toString();
    foto = json['foto'];
    noTelp = json['no_telp'].toString();
    level = json['level'].toString();
    levelUser = json['level_user'];
    areaCover = json['area_coverage'].toString();
    visit = json['visit'].toString();
    cekStok = json['cek_stok'].toString();
    idRegion = json['id_region'].toString();
    leaveBalance = json['leave_balance'].toString();
    createdAt = json['created_at'].toString();
    parentId = json['parent_id'].toString();
    namaParent = json['nama_parent'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama'] = nama;
    data['username'] = username;
    data['password'] = password;
    data['kode_cabang'] = kodeCabang;
    data['nama_cabang'] = namaCabang;
    data['nik'] = nik;
    data['foto'] = foto;
    data['lat'] = lat;
    data['long'] = long;
    data['no_telp'] = noTelp;
    data['level'] = level;
    data['level_user'] = levelUser;
    data['area_coverage'] = areaCover;
    data['visit'] = visit;
    data['cek_stok'] = cekStok;
    data['id_region'] = idRegion;
    data['leave_balance'] = leaveBalance;
    data['created_at'] = createdAt;
    data['parent_id'] = parentId;
    data['nama_parent'] = namaParent;
    return data;
  }
}
