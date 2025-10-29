import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/model/payslip_model.dart';

class PaySlipController extends GetxController {
  var isLoading = true.obs;
  // var payData = PayslipModel().obs;
  var paySlipFuture = Future<PayslipModel?>.value(null).obs;
  final datePeriode = TextEditingController();
  final initDate =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
            ),
          )
          .obs;
  final endDate =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                0,
              ).toString(),
            ),
          )
          .obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<PayslipModel?> getPaySlip({
    required String empId,
    required String date1,
    required String date2,
    required String branch,
  }) async {
    var data = {
      "emp_id": empId,
      "date1": date1,
      "date2": date2,
      "branch": branch,
    };
    final response = ServiceApi().getPaySlip(data);
    print(data);
    isLoading.value = false;
    return paySlipFuture.value = response;
  }
}
