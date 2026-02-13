import 'package:absensi/app/data/model/payslip_result_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/model/PayslipStoreModel.dart';
import '../../../data/model/payslip_model.dart';

class PaySlipController extends GetxController {
  var isLoading = true.obs;
  // var payData = PayslipModel().obs;
  var paySlipFuture = Future<PayslipResult?>.value(null).obs;
  var paySlipStoreFuture = Future<PayslipResult?>.value(null).obs;
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

  // 🔹 RANGE DATA PAYSLIP (hanya untuk UI constraint)
  final DateTime minDataDate = DateTime(2025, 9); // Sept 2025
  final DateTime maxDataDate = DateTime(2025, 12); // Des 2025
  // 🔹 RANGE DINAMIS DARI DATA YANG ADA
  final Rx<DateTime?> minAvailableDate = Rx<DateTime?>(null);
  final Rx<DateTime?> maxAvailableDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<PayslipResult?> getPaySlip({
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
    response.then((result) {
      if (result != null) {
        final selectedDate = DateTime.parse(date1);

        minAvailableDate.value ??= selectedDate;
        maxAvailableDate.value ??= selectedDate;

        if (selectedDate.isBefore(minAvailableDate.value!)) {
          minAvailableDate.value = selectedDate;
        }
        if (selectedDate.isAfter(maxAvailableDate.value!)) {
          maxAvailableDate.value = selectedDate;
        }
      }
    });
    isLoading.value = false;
    return paySlipFuture.value = response;
  }

  Future<PayslipResult?> getPaySlipStore({
    required String empId,
    required String date1,
    required String date2,
    required String branch,
  }) async {
    var storeData = {
      "emp_id": empId,
      "date1": date1,
      "date2": date2,
      "branch": branch,
    };
    final response = ServiceApi().getPaySlip(storeData);
    // print(storeData);
    response.then((result) {
      if (result != null) {
        final selectedDate = DateTime.parse(date1);

        minAvailableDate.value ??= selectedDate;
        maxAvailableDate.value ??= selectedDate;

        if (selectedDate.isBefore(minAvailableDate.value!)) {
          minAvailableDate.value = selectedDate;
        }
        if (selectedDate.isAfter(maxAvailableDate.value!)) {
          maxAvailableDate.value = selectedDate;
        }
      }
    });
    isLoading.value = false;
    return paySlipStoreFuture.value = response;
  }

  Future<DateTime?> showCustomMonthYearPicker(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    final months = DateFormat.MMM().dateSymbols.MONTHS;
    int selectedYear = initialDate?.year ?? DateTime.now().year;
    int selectedMonth = initialDate?.month ?? DateTime.now().month;

    DateTime? result;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ===== HEADER YEAR =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() => selectedYear--),
                      ),
                      Text(
                        selectedYear.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() => selectedYear++),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ===== MONTH GRID =====
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2,
                        ),
                    itemBuilder: (_, i) {
                      final isActive = selectedMonth == i + 1;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            selectedMonth = i + 1;
                          });

                          Future.delayed(const Duration(milliseconds: 120), () {
                            result = DateTime(selectedYear, selectedMonth);
                            Navigator.pop(context);
                          });
                        },
                        child: AnimatedScale(
                          scale: isActive ? 1.05 : 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color:
                                  isActive
                                      ? Colors.blue
                                      : Colors.blue.withOpacity(.12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              months[i],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return result;
  }
}
