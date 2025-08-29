import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/payslip_model.dart';
import 'package:absensi/app/modules/pay_slip/views/widget/pay_slip_desc.dart';
import 'package:absensi/app/modules/shared/dropdown.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../../data/helper/const.dart';
import '../controllers/pay_slip_controller.dart';

class PaySlipView extends GetView<PaySlipController> {
  PaySlipView({super.key, this.userData});
  final Data? userData;
  final payC = Get.find<PaySlipController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PaySlip', style: titleTextStyle.copyWith(fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.itemsBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DateTimeField(
                controller: payC.datePeriode,
                // style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                    // payC.getPaySlip(
                    //   empId: userData!.nik!,
                    //   date1: payC.initDate.value,
                    //   date2: payC.endDate.value,
                    //   branch: userData!.kodeCabang!,
                    // );
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
              Obx(
                () => FutureBuilder<PayslipModel?>(
                  future: payC.getPaySlip(
                    empId: userData!.nik!,
                    date1: payC.initDate.value,
                    date2: payC.endDate.value,
                    branch: userData!.kodeCabang!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Loading data.... '),
                          SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                Platform.isAndroid
                                    ? const CircularProgressIndicator()
                                    : const CupertinoActivityIndicator(),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return  Center(
                        child: Column(
                         mainAxisSize: MainAxisSize.min, // agar Column tidak mengambil seluruh tinggi
                            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/image/payslip.png', scale: 2,),
                            const SizedBox(height: 10,),
                            const Text('Tidak ada data slip gaji tersedia'),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text('Tidak ada data slip gaji tersedia'),
                      );
                    } else {
                      final payslip = snapshot.data!;
                      return PaySlipDesc(data: payslip);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
