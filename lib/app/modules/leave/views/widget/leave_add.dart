import 'dart:io';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/modules/leave/controllers/leave_controller.dart';
import 'package:absensi/app/modules/shared/dropdown.dart';
import 'package:absensi/app/modules/shared/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../../data/add_controller.dart';
import '../../../shared/date_picker.dart';
import '../../../shared/elevated_button.dart';

class LeaveAdd extends StatelessWidget {
  LeaveAdd({super.key, this.userData});
  final Data? userData;
  final leaveC = Get.find<LeaveController>();
  final adC = Get.put(AdController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Form Permohonan Cuti',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CsDatePicker(
                      controller: leaveC.datePick1,
                      editable: true,
                      label: 'Tanggal awal',
                    ),
                  ),
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
              CsDropDown(
                label: 'Mengajukan permohonan',
                items:
                    leaveC.listLeaves
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) {
                  leaveC.selectedLeave.value = val;
                },
              ),
              Obx(
                () => Visibility(
                  visible:
                      leaveC.selectedLeave.value == "Lain-lain, sebutkan"
                          ? true
                          : false,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CsTextField(
                        controller: leaveC.otherLeave,
                        label: 'Lainnya',
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DataTable(
                border: TableBorder.all(),
                headingRowHeight: 30,
                // headingRowColor: Colors.amber,
                columns: [
                  DataColumn(
                    label: Text(
                      'Saldo Cuti',
                      style: titleTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Jumlah yang diambil',
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
                        Center(
                          child: Text(
                            userData!.leaveBalance!,
                            style: titleTextStyle.copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: SizedBox(
                            height: 40,
                            // width: 50,
                            child: CsTextField(
                              label: '',
                              controller: leaveC.amtTkn,
                              onChanged: (val) {
                                leaveC.remainingOff(
                                  userData!.leaveBalance!,
                                  val,
                                );
                              },
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Obx(
                          () => Text(
                            leaveC.remainDays.value.toString(),
                            style: titleTextStyle.copyWith(fontSize: 18),
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
                label: 'Alasan kebutuhan cuti',
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              CsTextField(
                controller: leaveC.addrLeave,
                label: 'Alamat selama cuti',
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              CsTextField(
                controller: leaveC.phone,
                label: 'Phone',
                maxLines: 1,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<User>>(
                future: leaveC.getUserCabang(
                  userData!.kodeCabang!,
                  userData!.parentId!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    // Pastikan tidak ada duplikat (optional)
                    var uniqueUser = <User>[];
                    var seenUser = <String>{};
                    for (var usr in data) {
                      if (!seenUser.contains(usr.id!)) {
                        uniqueUser.add(usr);
                        seenUser.add(usr.id!);
                      }
                    }
                    // Validasi value dropdown dengan list dataCabang
                    final hasValueInItems = uniqueUser.any(
                      (e) => e.id == leaveC.selectedIdUser.value,
                    );
                    final dropdownValue =
                        hasValueInItems ? leaveC.selectedIdUser.value : null;
                    return DropdownButtonFormField<String>(
                      isExpanded:
                          true, // agar dropdown dan teks pas di lebar parent
                      value: dropdownValue,
                      items:
                          data.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.id!,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.nama!),
                                  Text(
                                    e.id!,
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    e.namaLevel!,
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            );
                          }).toList(),

                      onChanged: (val) {
                        if (val == null) return;
                        leaveC.selectedIdUser.value = val;
                        for (int i = 0; i < uniqueUser.length; i++) {
                          if (uniqueUser[i].id == val) {
                            leaveC.selectedLevelUser.value =
                                uniqueUser[i].level!;
                            leaveC.selectednamaLevel.value =
                                uniqueUser[i].namaLevel!;
                            break;
                          }
                        }
                        // leaveC.selectedIdUser.value = val ?? "";
                      },

                      // Tambahkan selectedItemBuilder untuk menampilkan teks terpilih dengan ellipsis
                      selectedItemBuilder: (BuildContext context) {
                        return data.map<Widget>((e) {
                          return Text(
                            e.nama!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: Colors.black),
                          );
                        }).toList();
                      },

                      decoration: const InputDecoration(
                        labelText: 'Selanjutnya, Tugas akan diserahkan kepada',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return Platform.isAndroid
                      ? const Center(child: CircularProgressIndicator())
                      : const Center(child: CupertinoActivityIndicator());
                },
              ),
              // Obx(
              //   () => Visibility(
              //     visible: leaveC.selectedIdUser.isNotEmpty ? true : false,
              //     child: Column(
              //       children: [
              //         const SizedBox(height: 10),
              //         CsTextField(
              //           controller:
              //               leaveC.nikUser..text = leaveC.selectedIdUser.value,
              //           label: 'NIK',
              //           maxLines: 1,
              //         ),
              //         const SizedBox(height: 10),
              //         CsTextField(
              //           controller:
              //               leaveC.levelUser
              //                 ..text = leaveC.selectednamaLevel.value,
              //           label: 'Position',
              //           maxLines: 1,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 10),
              CsElevatedButton(
                color: AppColors.itemsBackground,
                fontsize: 14,
                label: 'Tanda tangan',
                onPressed: () {
                  openDialogSign();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  openDialogSign() {
    Get.bottomSheet(
      Container(
        height: 250,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                  ),
                  onPressed: () => leaveC.ctrSign.clear(),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: AppColors.itemsBackground),
                  ),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.itemsBackground,
                  ),
                  onPressed: () async {
                    if (leaveC.datePick1.text.isEmpty ||
                        leaveC.datePick2.text.isEmpty) {
                      showToast("Tanggal cuti tidak boleh kosong");
                    } else if (leaveC.selectedLeave.value.isEmpty) {
                      showToast(
                        "Jenis pengajuan cuti tidak boleh kosong, harap pilih salah satu",
                      );
                    } else if (leaveC.selectedLeave.value ==
                            "Lain-lain, sebutkan" &&
                        leaveC.otherLeave.text.isEmpty) {
                      showToast("Harap isi jenis cuti pada kolom 'Lainnya'");
                    } else if (leaveC.amtTkn.text.isEmpty) {
                      showToast("Jumlah cuti yang diambil tidak boleh kosong");
                    } else if (leaveC.reasonLeave.text.isEmpty) {
                      showToast("Alasan kebutuhan cuti tidak boleh kosong");
                    } else if (leaveC.addrLeave.text.isEmpty) {
                      showToast("Alamat selama cuti tidak boleh kosong");
                    } else if (leaveC.phone.text.isEmpty) {
                      showToast("No Telp tidak boleh kosong");
                    } else if (leaveC.selectedIdUser.value.isEmpty) {
                      showToast(
                        "Harap pilih penanggung jawab tugas selama cuti",
                      );
                    } else if (leaveC.ctrSign.value.isEmpty) {
                      showToast("Harap buat tanda tangan dahulu");
                    } else {
                      await leaveC.submitLeaveReq(
                        cabang: userData!.kodeCabang!,
                        idUser: userData!.id!,
                        level: userData!.level!,
                        nama: userData!.nama!,
                        jumlahCuti: leaveC.amtTkn.text,
                        saldoCuti: userData!.leaveBalance!,
                        jenisCuti:
                            leaveC.otherLeave.text.isNotEmpty
                                ? leaveC.otherLeave.text
                                : leaveC.selectedLeave.value,
                        alasanCuti: leaveC.reasonLeave.text,
                        alamatCuti: leaveC.addrLeave.text,
                        telp: leaveC.phone.text,
                        userPengganti: leaveC.selectedIdUser.value,
                        levelUserPengganti: leaveC.selectedLevelUser.value,
                        parentId: userData!.parentId!,
                      );
                      adC.loadInterstitialAd();
                      adC.showInterstitialAd(() {});
                    }
                  },
                  child: const Text('Ajukan Cuti'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
