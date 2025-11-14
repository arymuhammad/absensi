import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/payslip_model.dart';
import 'package:absensi/app/data/model/payslip_result_model.dart';
import 'package:absensi/app/modules/pay_slip/views/widget/pay_slip_desc.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../../data/helper/const.dart';
import '../../../data/helper/currency_format.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/model/PayslipStoreModel.dart';
import '../controllers/pay_slip_controller.dart';
import 'widget/pay_slip_store_desc.dart';

class PaySlipView extends GetView<PaySlipController> {
  PaySlipView({super.key, this.userData});
  final Data? userData;
  final payC = Get.find<PaySlipController>();

  @override
  Widget build(BuildContext context) {
    late PayslipResult? payslip;
    late PayslipResult? payslipstore;
    return Scaffold(
      appBar: AppBar(
        title: Text('PaySlip', style: titleTextStyle.copyWith(fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.itemsBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DateTimeField(
              controller: payC.datePeriode,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                prefixIcon: Icon(Icons.calendar_month_sharp),
                hintText: 'Pilih Periode',
                border: OutlineInputBorder(),
              ),
              onChanged: (periode) {
                if (periode == null) {
                  payC.initDate.value = payC.initDate.value;
                  payC.endDate.value = payC.endDate.value;
                  payC.isLoading.value = true;
                  // payC.getPaySlip(
                  //   empId: userData!.nik!,
                  //   date1: payC.initDate.value,
                  //   date2: payC.endDate.value,
                  //   branch: userData!.kodeCabang!,
                  // );
                } else {
                  payC.initDate.value = DateFormat(
                    'yyyy-MM-dd',
                  ).format(periode);
                  payC.endDate.value = DateFormat(
                    'yyyy-MM-dd',
                  ).format(DateTime(periode.year, periode.month + 1, 0));
                  payC.isLoading.value = true;

                  userData!.kodeCabang == "HO000"
                      ? payC.getPaySlip(
                        empId: userData!.nik!,
                        date1: payC.initDate.value,
                        date2: payC.endDate.value,
                        branch: userData!.kodeCabang!,
                      )
                      : payC.getPaySlipStore(
                        empId: userData!.nik!,
                        date1: payC.initDate.value,
                        date2: payC.endDate.value,
                        branch: userData!.kodeCabang!,
                      );
                }
              },
              format: DateFormat("MMM yyyy"),
              onShowPicker: (context, currentValue) {
                return showMonthYearPicker(
                  context: context,
                  firstDate: DateTime(2000),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Obx(
                () => CustomMaterialIndicator(
                  onRefresh: () async {
                    if (userData!.kodeCabang! == "HO000") {
                      await payC.getPaySlip(
                        empId: userData!.nik!,
                        date1: payC.initDate.value,
                        date2: payC.endDate.value,
                        branch: userData!.kodeCabang!,
                      );
                      showToast('Page Refreshed');
                    } else {
                      await payC.getPaySlipStore(
                        empId: userData!.nik!,
                        date1: payC.initDate.value,
                        date2: payC.endDate.value,
                        branch: userData!.kodeCabang!,
                      );
                      showToast('Page Refreshed');
                    }
                  },
                  backgroundColor: Colors.white,
                  indicatorBuilder: (context, controller) {
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child:
                          Platform.isAndroid
                              ? CircularProgressIndicator(
                                color: AppColors.itemsBackground,
                                value:
                                    controller.state.isLoading
                                        ? null
                                        : math.min(controller.value, 1.0),
                              )
                              : const CupertinoActivityIndicator(),
                    );
                  },
                  child: FutureBuilder<PayslipResult?>(
                    future:
                        userData!.kodeCabang! == "HO000"
                            ? payC.paySlipFuture.value
                            : payC.paySlipStoreFuture.value,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/image/payslip.png', scale: 2),
                            const SizedBox(height: 10),
                            const Text('Tidak ada data slip gaji tersedia'),
                          ],
                        );
                      } else {
                        if (userData!.kodeCabang! == "HO000") {
                          payslip = snapshot.data! as PayslipResult?;
                        } else {
                          payslipstore = snapshot.data! as PayslipResult?;
                        }
                        return Stack(
                          children: [
                            ListView(
                              children: [
                                userData!.kodeCabang! == "HO000"
                                    ? PaySlipDesc(data: payslip!)
                                    : PaySlipStoreDesc(data: payslipstore!),
                              ],
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.itemsBackground,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TOTAL DITERIMA',
                                      style: titleTextStyle.copyWith(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormat.convertToIdr(
                                        int.parse(
                                          userData!.kodeCabang! == "HO000"
                                              ? payslip!
                                                  .payslipModel!
                                                  .totalReceivedByEmp!
                                              : payslipstore!
                                                  .payslipStoreModel!
                                                  .netSalaryRoundTf!,
                                        ),
                                        0,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            // Obx(
            //   () => FutureBuilder<PayslipModel?>(
            //     future: payC.getPaySlip(
            //       empId: userData!.nik!,
            //       date1: payC.initDate.value,
            //       date2: payC.endDate.value,
            //       branch: userData!.kodeCabang!,
            //     ),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             const Text('Loading data.... '),
            //             SizedBox(
            //               height: 20,
            //               width: 20,
            //               child:
            //                   Platform.isAndroid
            //                       ? const CircularProgressIndicator()
            //                       : const CupertinoActivityIndicator(),
            //             ),
            //           ],
            //         );
            //       } else if (snapshot.hasError) {
            //         return Center(
            //           child: Column(
            //             mainAxisSize:
            //                 MainAxisSize
            //                     .min, // agar Column tidak mengambil seluruh tinggi
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Image.asset('assets/image/payslip.png', scale: 2),
            //               const SizedBox(height: 10),
            //               const Text('Tidak ada data slip gaji tersedia'),
            //             ],
            //           ),
            //         );
            //       } else if (!snapshot.hasData || snapshot.data == null) {
            //         return const Center(
            //           child: Text('Tidak ada data slip gaji tersedia'),
            //         );
            //       } else {
            //         // final payslip = snapshot.data!;
            //         return ;
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
