import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:signature/signature.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/model/login_model.dart';
import '../../../../data/model/user_model.dart';
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
                        height: 45,
                        child: CsDropDown(
                          label: 'Mengajukan permohonan',
                          items:
                              leaveC.listLeaves
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            leaveC.selectedLeave.value = val;
                          },
                          isDark: isDark,
                        ),
                      ),

                      Obx(
                        () => Visibility(
                          visible:
                              leaveC.selectedLeave.value ==
                              "Lain-lain, sebutkan",
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              CsTextField(
                                controller: leaveC.otherLeave,
                                label: 'Lainnya',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔹 TABLE
                      DataTable(
                        border: TableBorder.all(),
                        headingRowHeight: 30,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Saldo Cuti',
                              style: titleTextStyle.copyWith(fontSize: 14),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Diambil',
                              style: titleTextStyle.copyWith(fontSize: 14),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Sisa Cuti',
                              style: titleTextStyle.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  userData!.leaveBalance!,
                                  style: titleTextStyle.copyWith(fontSize: 18),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  height: 40,
                                  width: 65,
                                  child: CsTextField(
                                    controller: leaveC.amtTkn,
                                    keyboardType: TextInputType.number,
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
                              DataCell(
                                Obx(
                                  () => Text(
                                    leaveC.remainDays.value.toString(),
                                    style: titleTextStyle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      CsTextField(
                        controller: leaveC.reasonLeave,
                        label: 'Alasan cuti',
                        maxLines: 3,
                        isDark: isDark,
                        icon: const Icon(FontAwesome.pencil_solid, size: 18),
                      ),

                      const SizedBox(height: 10),

                      CsTextField(
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
                        controller: leaveC.phone,
                        label: 'No WhatsApp aktif',
                        hint: '6285xxxxxx',
                        keyboardType: TextInputType.number,
                        isDark: isDark,
                        icon: const Icon(Iconsax.whatsapp_bold, size: 18),
                      ),

                      const SizedBox(height: 10),

                      //attach file
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () => leaveC.uploadFile(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GetBuilder<LeaveController>(
                                builder: (c) {
                                  if (c.image != null) {
                                    return Container(
                                      height: 65,
                                      width: 65,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                      ),
                                      child: Image.file(
                                        File(c.image!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      height: 65,
                                      width: 65,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt),
                                          Text('Upload'),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 5),
                              const Text('*Lampirkan file pendukung'),
                            ],
                          ),
                        ),
                      ),

                      /// 🔹 DROPDOWN USER
                      // FutureBuilder<List<User>>(
                      //   future: leaveC.getUserCabang(
                      //     userData!.kodeCabang!,
                      //     userData!.parentId!,
                      //   ),
                      //   builder: (context, snapshot) {
                      //     if (!snapshot.hasData) {
                      //       return const CircularProgressIndicator();
                      //     }

                      //     final data = snapshot.data!;

                      //     return DropdownButtonFormField<String>(
                      //       value:
                      //           leaveC.selectedIdUser.value.isEmpty
                      //               ? null
                      //               : leaveC.selectedIdUser.value,
                      //       items:
                      //           data
                      //               .map(
                      //                 (e) => DropdownMenuItem(
                      //                   value: e.id,
                      //                   child: Text(e.nama!),
                      //                 ),
                      //               )
                      //               .toList(),
                      //       onChanged: (val) {
                      //         if (val == null) return;
                      //         leaveC.selectedIdUser.value = val;
                      //       },
                      //       decoration: const InputDecoration(
                      //         labelText: 'Penanggung jawab',
                      //         border: OutlineInputBorder(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      const SizedBox(height: 10),

                      /// 🔹 SIGN BUTTON
                      CsElevatedButton(
                        color: AppColors.itemsBackground,
                        label: 'Tanda tangan',
                        fontsize: 14,
                        onPressed: () => openDialogSign(context),
                      ),

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

                    await leaveC.submitLeaveReq(
                      cabang: userData!.kodeCabang!,
                      idUser: userData!.id!,
                      level: userData!.level!,
                      nama: userData!.nama!,
                      jumlahCuti: leaveC.amtTkn.text,
                      saldoCuti: userData!.leaveBalance!,
                      jenisCuti: leaveC.selectedLeave.value,
                      alasanCuti: leaveC.reasonLeave.text,
                      alamatCuti: leaveC.addrLeave.text,
                      telp: leaveC.phone.text,
                      userPengganti: leaveC.selectedIdUser.value,
                      levelUserPengganti: leaveC.selectedLevelUser.value,
                      parentId: userData!.parentId!,
                    );
                    Get.back(); // tutup sheet
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
