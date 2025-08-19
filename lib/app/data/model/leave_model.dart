class LeaveModel {
  late String? uid;
  late String? idUser;
  late String? nama;
  late String? cabang;
  late String? namaCabang;
  late String? levelId;
  late String? namaLevel;
  late String? parentId;
  late String? jenisCuti;
  late String? tgl1;
  late String? tgl2;
  late String? jumlahCuti;
  late String? alasan;
  late String? alamat;
  late String? telp;
  late String? idUserPengganti;
  late String? userPengganti;
  late String? levelUserPengganti;
  late String? acc1;
  late String? namaAcc1;
  late String? acc2;
  late String? namaAcc2;
  late String? acc3;
  late String? namaAcc3;
  late String? tglBuat;
  late String? sign;

  LeaveModel({
    this.uid,
    this.idUser,
    this.nama,
    this.cabang,
    this.namaCabang,
    this.levelId,
    this.namaLevel,
    this.parentId,
    this.jenisCuti,
    this.tgl1,
    this.tgl2,
    this.jumlahCuti,
    this.alasan,
    this.alamat,
    this.telp,
    this.idUserPengganti,
    this.userPengganti,
    this.levelUserPengganti,
    this.acc1,
    this.namaAcc1,
    this.acc2,
    this.namaAcc2,
    this.acc3,
    this.namaAcc3,
    this.tglBuat,
    this.sign,
  });

  LeaveModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    idUser = json['id_user'];
    nama = json['nama'];
    cabang = json['kode_cabang'];
    namaCabang = json['nama_cabang'];
    levelId = json['level']??'';
    namaLevel = json['levelMain']??'';
    parentId = json['parent_id']??'';
    jenisCuti = json['jenis_cuti'];
    tgl1 = json['tanggal_mulai'];
    tgl2 = json['tanggal_selesai'];
    jumlahCuti = json['jumlah_cuti'];
    alasan = json['alasan_cuti'];
    alamat = json['alamat'];
    telp = json['telp'];
    idUserPengganti = json['id_user_pengganti'];
    userPengganti = json['user_pengganti']??'';
    levelUserPengganti = json['levelPengganti']??'';
    acc1 = json['acc_1'];
    namaAcc1 = json['nama_acc_1'];
    acc2 = json['acc_2'];
    namaAcc2 = json['nama_acc_2'];
    acc3 = json['acc_3'];
    namaAcc3 = json['nama_acc_3'];
    tglBuat = json['tgl_buat'];
    sign = json['sign'];
  }
}
