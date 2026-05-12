class ReqApp {
  late String id;
  late String idUser;
  late String nama;
  late String namaCabang;
  late String tglMasuk;
  String? tglPulang;
  String? idShift;
  String? jamMasuk;
  String? jamPulang;
  String? jamAbsenMasuk;
  String? jamAbsenPulang;
  String? fotoMasuk;
  String? fotoPulang;
  String? latOut;
  String? longOut;
  String? devInfo;
  String? status;
  String? statusExcep;
  String? acc1;
  String? acc2;
  String? acc3;
  String? acc4;
  String? keterangan;
  String? alasan;
  String? namaShift;
  String? isRead;

  ReqApp({
    required this.id,
    required this.idUser,
    required this.nama,
    required this.namaCabang,
    required this.tglMasuk,
    this.tglPulang,
    this.idShift,
    this.jamMasuk,
    this.jamPulang,
    this.jamAbsenMasuk,
    this.jamAbsenPulang,
    this.fotoMasuk,
    this.fotoPulang,
    this.latOut,
    this.longOut,
    this.devInfo,
    this.status,
    this.statusExcep,
    this.acc1,
    this.acc2,
    this.acc3,
    this.acc4,
    this.keterangan,
    this.alasan,
    this.namaShift,
    this.isRead
  });

  ReqApp.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idUser = json['id_user'];
    nama = json['nama']??'';
    namaCabang = json['nama_cabang']??'';
    tglMasuk = json['tgl_masuk'];
    tglPulang = json['tgl_pulang']??'';
    idShift = json['id_shift']??'';
    jamMasuk = json['jam_masuk']??'';
    jamPulang = json['jam_pulang']??'';
    jamAbsenMasuk = json['jam_absen_masuk']??'';
    jamAbsenPulang = json['jam_absen_pulang']??'';
    fotoMasuk = json['foto_masuk']??'';
    fotoPulang = json['foto_pulang']??'';
    status = json['status']??'';
    statusExcep = json['status_excep']??'';
    latOut = json['lat_out']??'';
    longOut = json['long_out']??'';
    devInfo = json['device_info2']??'';
    acc1 = json['acc_1']??'';
    acc2 = json['acc_2']??'';
    acc3 = json['acc_3']??'';
    acc4 = json['acc_4']??'';
    keterangan = json['keterangan']??'';
    alasan = json['alasan']??'';
    namaShift = json['nama_shift']??'';
    isRead = json['is_read']??'';
  }
}
