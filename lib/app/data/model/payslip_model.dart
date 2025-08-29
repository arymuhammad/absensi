class PayslipModel {
  late String? periode;
  late String? empId;
  late String? empName;
  late String? position;
  late String? joinDate;
  late String? totalWorkDay;
  late String? basicSalary;
  late String? refund;
  late String? allowance;
  late String? bpjs;
  late String? lateCut;
  late String? absentCut;
  late String? sickCut;
  late String? clearanceCut;
  late String? pijarCut;
  late String? totalReceipts;
  late String? totalCut;
  late String? totalReceivedByEmp;
  late String? createdAt;

  PayslipModel({
    this.periode,
    this.empId,
    this.empName,
    this.position,
    this.joinDate,
    this.totalWorkDay,
    this.basicSalary,
    this.refund,
    this.allowance,
    this.bpjs,
    this.lateCut,
    this.absentCut,
    this.sickCut,
    this.clearanceCut,
    this.pijarCut,
    this.totalReceipts,
    this.totalCut,
    this.totalReceivedByEmp,
    this.createdAt,
  });

  PayslipModel.fromJson(Map<String,dynamic>json){
     periode=json['periode'];
    empId=json['emp_id'];
    empName=json['emp_name'];
    position=json['position'];
    joinDate=json['join_date'];
    totalWorkDay=json['total_work_days'];
    basicSalary=json['basic_salary'];
    refund=json['refund'];
    allowance=json['allowance'];
    bpjs=json['bpjs'];
    lateCut=json['late_cut'];
    absentCut=json['absent_cut'];
    sickCut=json['sick_cut'];
    clearanceCut=json['clearance_cut'];
    pijarCut=json['pijar_cut'];
    totalReceipts=json['total_receipts'];
    totalCut=json['total_cut'];
    totalReceivedByEmp=json['total_received_by_emp'];
    createdAt=json['created_at'];
  }
}
