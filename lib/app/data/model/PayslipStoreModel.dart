class PayslipStoreModel {
  late String? periode;
  late String? empId;
  late String? empName;
  late String? position;
  late String? joinDate;
  late String? tk;
  late String? basicSalary;
  late String? allowance;
  late String? payPerDay;
  late String? netSalary;
  late String? tk2;
  late String? presenceAllowance;
  late String? totalJab;
  late String? perDay;
  late String? rangeSubsidy;
  late String? boardingAllowance;
  late String? holidayOvertime;
  late String? overtime;
  late String? bonus;
  late String? refund;
  late String? totalIncome;
  late String? deposit;
  late String? late;
  late String? ais;
  late String? uniform;
  late String? so;
  late String? totalCut;
  late String? netSalary2;
  late String? netSalaryRoundTf;
  late String? rekBri;
  late String? createdAt;

  PayslipStoreModel({
    this.periode,
    this.empId,
    this.empName,
    this.position,
    this.joinDate,
    this.tk,
    this.basicSalary,
    this.allowance,
    this.payPerDay,
    this.netSalary,
    this.tk2,
    this.presenceAllowance,
    this.totalJab,
    this.perDay,
    this.rangeSubsidy,
    this.boardingAllowance,
    this.holidayOvertime,
    this.overtime,
    this.bonus,
    this.refund,
    this.totalIncome,
    this.deposit,
    this.late,
    this.ais,
    this.uniform,
    this.so,
    this.totalCut,
    this.netSalary2,
    this.netSalaryRoundTf,
    this.rekBri,
    this.createdAt,
  });

  PayslipStoreModel.fromJson(Map<String, dynamic> json) {
    periode = json['periode'];
    empId = json['emp_id'];
    empName = json['emp_name'];
    position = json['position'];
    joinDate = json['join_date'];
    tk = json['tk'];
    basicSalary = json['basic_salary'];
    allowance = json['allowance'];
    payPerDay = json['pay_per_day'];
    netSalary = json['net_salary'];
    tk2 = json['tk_2'];
    presenceAllowance = json['presence_allowance'];
    totalJab = json['total_jab'];
    perDay = json['per_day'];
    rangeSubsidy = json['range_subsidy'];
    boardingAllowance = json['boarding_allowance'];
    holidayOvertime = json['holiday_overtime'];
    overtime = json['overtime'];
    bonus = json['bonus'];
    refund = json['refund'];
    totalIncome = json['total_income'];
    deposit = json['deposit'];
    late = json['late'];
    ais = json['ais'];
    uniform = json['uniform'];
    so = json['so'];
    totalCut = json['total_cut'];
    netSalary2 = json['net_salary_2'];
    netSalaryRoundTf = json['net_salary_round_tf'];
    rekBri = json['rek_bri'];
    createdAt = json['created_at'];
  }
}
