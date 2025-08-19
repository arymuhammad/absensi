import 'dart:io';
import 'dart:math';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/detail_absen/controllers/detail_absen_controller.dart';
import 'package:absensi/app/modules/shared/date_picker.dart';
import 'package:absensi/app/modules/shared/text_field.dart';
import 'package:absensi/app/modules/shared/time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/dropdown_shift_kerja.dart';
import '../../../shared/elevated_button_icon.dart';

class EditDataAbsen extends GetView<DetailAbsenController> {
  EditDataAbsen({super.key, required this.data});
  final Map<String, dynamic> data;
  final detailC = Get.put(DetailAbsenController());
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Data Absen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.mediaQuery.size.width / 2.2,
                    child: CsDatePicker(
                      editable: false,
                      controller:
                          detailC.tglMasuk..text = data['tanggal_masuk'],
                      label: 'Entry Date',
                    ),
                  ),
                  SizedBox(
                    width: Get.mediaQuery.size.width / 2.2,
                    child: CsDatePicker(
                      editable: true,
                      controller: detailC.tglPulang,
                      label: 'Return Date',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                // height: 52,
                child: CsDropdownShiftKerja(
                  page: 'edit_data_absen',
                  value:
                      detailC.selectedShift.value == ""
                          ? null
                          : detailC.selectedShift.value,
                  onChanged: (val) {
                    for (int i = 0; i < detailC.shiftKerja.length; i++) {
                      if (detailC.shiftKerja[i].id == val) {
                        detailC.selectedShift.value = val!;
                        detailC.jamMasuk.value =
                            detailC.shiftKerja[i].jamMasuk!;
                        detailC.jamPulang.value =
                            detailC.shiftKerja[i].jamPulang!;
                      }
                    }
                    dialogMsg(
                      'INFO',
                      'Make sure the work shift selected \nis appropriate',
                    );
                  },
                  // },
                ),
              ),
              // const SizedBox(
              //   height: 5,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.mediaQuery.size.width / 2.2,
                    child: CsTimePicker(
                      controller: detailC.jamAbsenMasuk,
                      label: 'Check In',
                      jam: data['jam_absen_masuk'],
                      info: '',
                    ),
                  ),
                  SizedBox(
                    width: Get.mediaQuery.size.width / 2.2,
                    child: CsTimePicker(
                      controller: detailC.jamAbsenPulang,
                      label: 'Check Out',
                      jam: data['jam_absen_pulang'],
                      info: '',
                    ),
                  ),
                ],
              ),
              // const SizedBox(
              //   height: 5,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text('Proof of Entry'),
                      InkWell(
                        onTap: () {
                          detailC.pickImg();
                        },
                        child: GetBuilder<DetailAbsenController>(
                          builder:
                              (c) => Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(),
                                ),
                                child:
                                    c.image != null
                                        ? Card(
                                          child: Image.file(
                                            File(c.image!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.camera_front_rounded,
                                        ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Proof of Return'),
                      InkWell(
                        onTap: () {
                          detailC.pickImg2();
                        },
                        child: GetBuilder<DetailAbsenController>(
                          builder:
                              (c) => Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(),
                                ),
                                child:
                                    c.image2 != null
                                        ? Card(
                                          child: Image.file(
                                            File(c.image2!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.camera_front_rounded,
                                        ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: CsTextField(
                  controller: detailC.alasan,
                  label: 'Reason for data change',
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CsElevatedButtonIcon(
                  icon: Transform.rotate(
                    angle: 180 * pi / 100,
                    child: const Icon(Icons.send_outlined),
                  ),
                  fontSize: 18,
                  label: 'Request Approval',
                  onPressed: () {
                    detailC.submitApproval(data['id_user'], data['nama']);
                  },
                  backgroundColor: AppColors.itemsBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
