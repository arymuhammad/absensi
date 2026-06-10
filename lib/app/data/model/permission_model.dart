class PermissionModel {
  String? id;
  String? idUser;
  String? nama;
  String? level;
  String? namaCabang;
  String? tanggalMulai;
  String? tanggalSelesai;
  String? alasan;
  String? lampiran;

  String? acc1;
  String? acc2;
  String? acc3;
  String? acc4;

  String? noteAcc1;
  String? noteAcc2;
  String? noteAcc3;
  String? noteAcc4;

  String? createdAt;
  String? status;

  PermissionModel({
    this.id,
    this.idUser,
    this.nama,
    this.level,
    this.namaCabang,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.alasan,
    this.lampiran,
    this.acc1,
    this.acc2,
    this.acc3,
    this.acc4,
    this.noteAcc1,
    this.noteAcc2,
    this.noteAcc3,
    this.noteAcc4,
    this.createdAt,
    this.status,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id']?.toString(),
      idUser: json['id_user']?.toString(),
      nama: json['nama']?.toString(),
      level: json['level']?.toString(),
      namaCabang: json['nama_cabang']?.toString(),
      tanggalMulai: json['tanggal_mulai']?.toString(),
      tanggalSelesai: json['tanggal_selesai']?.toString(),
      alasan: json['alasan']?.toString(),
      lampiran: json['lampiran']?.toString(),

      acc1: json['acc_1']?.toString(),
      acc2: json['acc_2']?.toString(),
      acc3: json['acc_3']?.toString(),
      acc4: json['acc_4']?.toString(),

      noteAcc1: json['note_acc_1']?.toString(),
      noteAcc2: json['note_acc_2']?.toString(),
      noteAcc3: json['note_acc_3']?.toString(),
      noteAcc4: json['note_acc_4']?.toString(),

      createdAt: json['created_at']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'nama': nama,
      'level': level,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'alasan': alasan,
      'lampiran': lampiran,
      'acc_1': acc1,
      'acc_2': acc2,
      'acc_3': acc3,
      'acc_4': acc4,
      'note_acc_1': noteAcc1,
      'note_acc_2': noteAcc2,
      'note_acc_3': noteAcc3,
      'note_acc_4': noteAcc4,
      'created_at': createdAt,
      'status': status,
    };
  }
}
