import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:signature/signature.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/model/login_model.dart';
import '../../../shared/date_picker.dart';
import '../../../shared/dropdown.dart';
import '../../../shared/elevated_button.dart';
import '../../../shared/text_field.dart';
import '../../controllers/leave_controller.dart';

class LeaveAddSheet extends StatelessWidget {
  LeaveAddSheet({super.key, this.userData});

  final Data? userData;
  final leaveC = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.80,
      minChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 🔹 HANDLE
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // 🔹 TITLE
              Text(
                'Form Permohonan Cuti',
                style: titleTextStyle.copyWith(fontSize: 16),
              ),

              const Divider(),

              // 🔹 CONTENT
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CsDatePicker(
                              controller: leaveC.datePick1,
                              editable: true,
                              label: 'Tanggal awal',
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: CsDatePicker(
                              controller: leaveC.datePick2,
                              editable: true,
                              label: 'Tanggal akhir',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        child: CsDropDown(
                          label: 'Mengajukan permohonan',
                          items:
                              leaveC.leaveType
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            leaveC.selectedLeaveType.value = val;
                          },
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Obx(() {
                        if (leaveC.selectedLeaveType.value != "Lainnya") {
                          return const SizedBox();
                        }
                        final data = leaveC.leaveList;
                        return CsDropDown(
                          items:
                              data
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.name,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(e.name!),
                                          Text('${e.duration!} Hari'),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),

                          value:
                              leaveC.selectedLeave.value.isNotEmpty
                                  ? leaveC.selectedLeave.value
                                  : null,

                          onChanged: (val) {
                            leaveC.selectedLeave.value = val;
                            // print(leaveC.selectedLeave.value);

                            final selected = data.firstWhere(
                              (e) => e.name == val,
                              orElse: () => data.first,
                            );

                            leaveC.amtTkn.text = selected.duration.toString();
                            leaveC.remainingOff(
                              userData!.leaveBalance!,
                              selected.duration!,
                            );
                          },
                          selectedItemBuilder: (context) {
                            return data.map((e) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.name!),
                                  Text(' - ${e.duration!} Hari'),
                                ],
                              );
                            }).toList();
                          },

                          label: 'Pilih jenis cuti',
                          isDark: isDark,
                        );
                      }),

                      const SizedBox(height: 10),

                      /// 🔹 TABLE
                      Obx(
                        () => Visibility(
                          visible:
                              leaveC.selectedLeave.value != "Replacement Off",
                          child: Column(
                            children: [
                              DataTable(
                                border: TableBorder.all(),
                                headingRowHeight: 30,
                                columns: const [
                                  DataColumn(label: Text('Saldo Cuti')),
                                  DataColumn(label: Text('Diambil')),
                                  DataColumn(label: Text('Sisa Cuti')),
                                ],
                                rows: [
                                  DataRow(
                                    cells: [
                                      DataCell(Text(userData!.leaveBalance!)),
                                      DataCell(
                                        SizedBox(
                                          height: 40,
                                          width: 65,
                                          child: Obx(
                                            () => CsTextField(
                                              enabled:
                                                  leaveC
                                                      .selectedLeaveType
                                                      .value !=
                                                  "Lainnya",
                                              controller: leaveC.amtTkn,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLines: 1,
                                              onChanged: (val) {
                                                leaveC.remainingOff(
                                                  userData!.leaveBalance!,
                                                  val,
                                                );
                                              },
                                              label: '',
                                              isDark: isDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Obx(
                                          () => Text(
                                            leaveC.remainDays.value.toString(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),

                      CsTextField(
                        enabled: true,
                        controller: leaveC.reasonLeave,
                        label: 'Alasan cuti',
                        maxLines: 3,
                        isDark: isDark,
                        icon: const Icon(FontAwesome.pencil_solid, size: 18),
                      ),

                      const SizedBox(height: 10),

                      CsTextField(
                        enabled: true,
                        controller: leaveC.addrLeave,
                        label: 'Alamat cuti',
                        maxLines: 3,
                        isDark: isDark,
                        icon: const Icon(
                          FontAwesome.house_user_solid,
                          size: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      CsTextField(
                        enabled: true,
                        controller: leaveC.phone,
                        label: 'No WhatsApp aktif',
                        hint: '6285xxxxxx',
                        keyboardType: TextInputType.number,
                        isDark: isDark,
                        icon: const Icon(Iconsax.whatsapp_bold, size: 18),
                      ),

                      const SizedBox(height: 10),

                      //attach file
                      Obx(
                        () => Visibility(
                          visible:
                              leaveC.selectedLeaveType.value == "Lainnya" &&
                              leaveC.selectedLeave.value != "Replacement Off",
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: InkWell(
                              onTap: () => leaveC.uploadFile(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GetBuilder<LeaveController>(
                                        builder: (c) {
                                          return Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              ...List.generate(c.images.length, (
                                                index,
                                              ) {
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      width: 65,
                                                      height: 65,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.file(
                                                          File(
                                                            c
                                                                .images[index]
                                                                .path,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),

                                                    Positioned(
                                                      top: -5,
                                                      right: -5,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.cancel,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () {
                                                          c.images.removeAt(
                                                            index,
                                                          );
                                                          c.update();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),

                                              if (c.images.length < 3)
                                                InkWell(
                                                  onTap: c.uploadFile,
                                                  child: Container(
                                                    width: 65,
                                                    height: 65,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.add_a_photo),
                                                        Text("Upload"),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    '*Upload file pendukung (Max 3 file)',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Obx(
                        () => Visibility(
                          visible:
                              leaveC.selectedLeave.value == "Replacement Off",
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Note',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '*Replacement Off tidak akan mengurangi saldo cuti',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),

                      /// 🔹 SIGN BUTTON
                      Obx(() {
                        final int totalLeave =
                            int.tryParse(leaveC.amtTkn.text) ?? 0;

                        final bool invalidLeave =
                            leaveC.remainDays.value < 0 || totalLeave <= 0;
                        return CsElevatedButton(
                          color: AppColors.itemsBackground,
                          label:
                              totalLeave <= 0
                                  ? 'Jumlah cuti harus lebih dari 0'
                                  : leaveC.remainDays.value < 0
                                  ? 'Saldo cuti tidak cukup'
                                  : 'Tanda tangan',
                          fontsize: 14,
                          onPressed:
                              leaveC.selectedLeaveType.value.isEmpty ||
                                      invalidLeave
                                  ? null
                                  : () {
                                    if (leaveC.images.isEmpty &&
                                        leaveC.selectedLeaveType.value ==
                                            "Lainnya" &&
                                        leaveC.selectedLeave.value !=
                                            "Replacement Off") {
                                      showToast('Upload file pendukung');
                                    } else {
                                      openDialogSign(context);
                                    }
                                  },
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔥 SIGNATURE (TETAP SAMA LOGIC LU)
  void openDialogSign(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 250,
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Column(
          children: [
            Signature(
              controller: leaveC.ctrSign,
              height: 150,
              backgroundColor: Colors.grey[300]!,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => leaveC.ctrSign.clear(),
                  child: const Text('Hapus'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 🔥 VALIDASI LU TETAP
                    if (leaveC.datePick1.text.isEmpty ||
                        leaveC.datePick2.text.isEmpty) {
                      showToast("Tanggal kosong");
                      return;
                    }

                    if (leaveC.reasonLeave.text.isEmpty) {
                      showToast("Harap isi alasan cuti");
                      return;
                    }
                    if (leaveC.addrLeave.text.isEmpty) {
                      showToast("Harap isi alamat selama cuti");
                      return;
                    }

                    if (leaveC.phone.text.isEmpty) {
                      showToast("Harap isi no whatsapp aktif");
                      return;
                    }

                    if (leaveC.ctrSign.isEmpty) {
                      showToast("Harap buat tanda tangan dahulu");
                      return;
                    }

                    await leaveC.submitLeaveReq(
                      cabang: userData!.kodeCabang!,
                      idUser: userData!.id!,
                      level: userData!.level!,
                      nama: userData!.nama!,
                      jumlahCuti: leaveC.amtTkn.text,
                      saldoCuti: userData!.leaveBalance!,
                      jenisCuti:
                          leaveC.selectedLeave.value.isNotEmpty
                              ? leaveC.selectedLeave.value
                              : leaveC.selectedLeaveType.value,
                      alasanCuti: leaveC.reasonLeave.text,
                      alamatCuti: leaveC.addrLeave.text,
                      telp: leaveC.phone.text,
                      // userPengganti: leaveC.selectedIdUser.value,
                      // levelUserPengganti: leaveC.selectedLevelUser.value,
                      parentId: userData!.parentId!,
                    );
                    // Get.back(); // tutup sheet
                  },
                  child: const Text('Ajukan'),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
