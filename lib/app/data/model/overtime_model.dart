class OvertimeModel {
  String? id;
  String? branchCode;
  String? branchName;
  String? name;
  String? level;
  String? photo;
  String? initDate;
  String? endDate;
  String? start;
  String? end;
  String? remark;
  String? status;
  String? acc1;
  String? acc2;
  String? acc3;
  String? acc4;

  OvertimeModel({
    this.id,
    this.branchCode,
    this.branchName,
    this.name,
    this.level,
    this.photo,
    this.initDate,
    this.endDate,
    this.start,
    this.end,
    this.remark,
    this.status,
    this.acc1,
    this.acc2,
    this.acc3,
    this.acc4,
  });

  OvertimeModel.fromJson(Map<String, dynamic> json) {
    id = json['id_user'];
    branchCode = json['branch_code'];
    branchName = json['nama_cabang'];
    name = json['name'];
    level = json['level'];
    photo = json['photo'];
    initDate = json['init_date'];
    endDate = json['end_date'];
    start = json['start'];
    end = json['end'];
    remark = json['remark'];
    status = json['status'];
    acc1 = json['acc_1'];
    acc2 = json['acc_2'];
    acc3 = json['acc_3'];
    acc4 = json['acc_4'];
  }
}
