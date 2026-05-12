import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:startapp_sdk/startapp.dart';
import 'package:step_progress/step_progress.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/helper_ui.dart';
import '../../../data/model/req_leave_model.dart';
import '../../../services/service_api.dart';
import '../../approval/widget/bottom_search_live.dart';
import '../../login/controllers/login_controller.dart';
import '../../shared/container_main_color.dart';
import '../controllers/leave_controller.dart';
import 'widget/leave_add_sheet.dart';

class LeaveView extends GetView<LeaveController> {
  LeaveView({super.key});

  final auth = Get.find<LoginController>();
  final leaveC = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
    final userData = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leave',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              BuildContext? dialogContext;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) {
                  dialogContext = ctx;

                  return const Center(child: CircularProgressIndicator());
                },
              );

              await leaveC.leaveBalanceCheck(userData);

              if (dialogContext != null) {
                Navigator.of(dialogContext!).pop();
              }

              final newUserData = auth.logUser.value;

              leaveC.generateUid();

              if (newUserData.leaveBalance == "0") {
                showToast(
                  "Saldo Cuti Anda Habis\nAnda tidak dapat mengajukan permohonan cuti",
                );

                return;
              }

              Get.bottomSheet(
                LeaveAddSheet(userData: newUserData),
                isScrollControlled: true,
              );
            },
            icon: const Icon(Icons.format_list_bulleted_add),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient(
              context: context,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 5),

              Expanded(
                child: CustomMaterialIndicator(
                  onRefresh: () async {
                    //  leaveC.leaveBalanceCheck(userData!);
                    await leaveC.getLeaveReq({
                      "type": "",
                      "id_user": userData.id!,
                    });
                    showToast('Page Refreshed');
                    // leaveC.isLoading.value = true;
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
                  child: Obx(
                    () =>
                        leaveC.isLoading.value
                            ? const Center(child: CupertinoActivityIndicator())
                            : leaveC.listLeaveReq.isEmpty
                            ? ListView(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              // physics: NeverScrollableScrollPhysics(), // agar tidak bisa scroll
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(
                                        context,
                                      ).size.height, // tinggi layar penuh
                                  child: const Center(
                                    child: Text(
                                      'Belum ada data pengajuan cuti',
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Padding(
                              padding: const EdgeInsets.fromLTRB(
                                8.0,
                                0.0,
                                8.0,
                                8.0,
                              ),
                              child: ListView(
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ExpansionTileGroup(
                                        toggleType:
                                            ToggleType.expandOnlyCurrent,
                                        spaceBetweenItem: 5,
                                        children: List.generate(leaveC.listLeaveReq.length, (
                                          i,
                                        ) {
                                          final leave = leaveC.listLeaveReq[i];

                                          // ================== STEP CONFIG ==================
                                          List<String> getNodeTitles(
                                            ReqLeaveModel leave,
                                          ) {
                                            if (leave.parentId == "3") {
                                              final skipStore =
                                                  leave.levelId == "19" ||
                                                  leave.levelId == "20";

                                              if (skipStore) {
                                                return [
                                                  'Apply',
                                                  'Area Manager',
                                                  'Ops',
                                                  'HR',
                                                ];
                                              }

                                              return [
                                                'Apply',
                                                'Store Manager',
                                                'Area Manager',
                                                'Ops',
                                                'HR',
                                              ];
                                            }

                                            if (leave.parentId == "2") {
                                              return [
                                                'Apply',
                                                (leave.levelId == "29" ||
                                                        leave.levelId == "80" ||
                                                        leave.levelId == "60")
                                                    ? 'General Manager'
                                                    : 'Operational Manager',
                                                'HR',
                                              ];
                                            }

                                            if (leave.parentId == "4") {
                                              return [
                                                'Apply',
                                                leave.levelId != '43'
                                                    ? 'IT Manager'
                                                    : 'General Manager',
                                                'HR',
                                              ];
                                            }

                                            if (leave.parentId == "5") {
                                              return [
                                                'Apply',
                                                leave.levelId != '77'
                                                    ? 'EDITORIAL Manager'
                                                    : 'General Manager',
                                                'HR',
                                              ];
                                            }

                                            if (leave.parentId == "8") {
                                              return [
                                                'Apply',
                                                leave.levelId != '18'
                                                    ? 'HR Manager'
                                                    : 'General Manager',
                                                'HR',
                                              ];
                                            }

                                            if (leave.parentId == "9") {
                                              return [
                                                'Apply',
                                                leave.levelId != '41'
                                                    ? 'Brand Manager'
                                                    : 'General Manager',
                                                'HR',
                                              ];
                                            }

                                            return [
                                              'Apply',
                                              'Store Manager',
                                              'Area Manager',
                                              'HR',
                                            ];
                                          }

                                          // ================== APPROVAL MAPPING ==================
                                          String? getApprovalValue(
                                            ReqLeaveModel leave,
                                            int index,
                                          ) {
                                            if (leave.parentId == "3") {
                                              final skipStore =
                                                  leave.levelId == "19" ||
                                                  leave.levelId == "20";

                                              if (skipStore) {
                                                switch (index) {
                                                  case 1:
                                                    return leave.acc2;
                                                  case 2:
                                                    return leave.acc3;
                                                  case 3:
                                                    return leave.acc4;
                                                  default:
                                                    return null;
                                                }
                                              } else {
                                                switch (index) {
                                                  case 1:
                                                    return leave.acc1;
                                                  case 2:
                                                    return leave.acc2;
                                                  case 3:
                                                    return leave.acc3;
                                                  case 4:
                                                    return leave.acc4;
                                                  default:
                                                    return null;
                                                }
                                              }
                                            }

                                            // 🔥 INI YANG DIPERBAIKI
                                            // selain parentId 3 → hanya pakai acc2 & acc4
                                            switch (index) {
                                              case 1:
                                                return leave.acc2; // atasan
                                              case 2:
                                                return leave.acc4; // HR
                                              default:
                                                return null;
                                            }
                                          }

                                          // ================== STATUS ==================
                                          String getStepStatus(
                                            ReqLeaveModel leave,
                                          ) {
                                            bool isEmpty(String? val) =>
                                                val == null || val.isEmpty;

                                            // 🔴 reject tetap global
                                            if (leave.acc1 == 'reject' ||
                                                leave.acc2 == 'reject' ||
                                                leave.acc3 == 'reject' ||
                                                leave.acc4 == 'reject') {
                                              return "rejected";
                                            }

                                            // ======================
                                            // 🔥 KHUSUS PARENT 3
                                            // ======================
                                            if (leave.parentId == "3") {
                                              final skipStore =
                                                  leave.levelId == "19" ||
                                                  leave.levelId == "20";

                                              if (skipStore) {
                                                // acc2 → acc3 → acc4
                                                if (isEmpty(leave.acc2) ||
                                                    isEmpty(leave.acc3) ||
                                                    isEmpty(leave.acc4)) {
                                                  return "pending";
                                                }
                                              } else {
                                                // acc1 → acc2 → acc3 → acc4
                                                if (isEmpty(leave.acc1) ||
                                                    isEmpty(leave.acc2) ||
                                                    isEmpty(leave.acc3) ||
                                                    isEmpty(leave.acc4)) {
                                                  return "pending";
                                                }
                                              }

                                              return "approved";
                                            }

                                            // ======================
                                            // 🔥 SEMUA PARENT LAIN
                                            // ======================
                                            // Apply → Atasan → HR
                                            // 👉 acc2 & acc4 doang
                                            if (isEmpty(leave.acc2) ||
                                                isEmpty(leave.acc4)) {
                                              return "pending";
                                            }

                                            return "approved";
                                          }

                                          // ================== COLOR ==================
                                          Color getStepColor(
                                            ReqLeaveModel leave,
                                            int index,
                                          ) {
                                            final val = getApprovalValue(
                                              leave,
                                              index,
                                            );

                                            if (index == 0) return Colors.green;

                                            bool previousApproved = true;

                                            for (int i = 1; i < index; i++) {
                                              final prevVal = getApprovalValue(
                                                leave,
                                                i,
                                              );
                                              if (prevVal == null ||
                                                  prevVal == 'reject') {
                                                previousApproved = false;
                                                break;
                                              }
                                            }

                                            if (val == 'reject') return red!;
                                            if (!previousApproved ||
                                                val == null) {
                                              return Colors.grey;
                                            }

                                            return Colors.green;
                                          }

                                          // ================== ICON ==================
                                          Widget buildStepIcon(
                                            ReqLeaveModel leave,
                                            int index,
                                          ) {
                                            if (index == 0) {
                                              return const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 18,
                                              );
                                            }

                                            final val = getApprovalValue(
                                              leave,
                                              index,
                                            );

                                            // ❌ kalau step ini reject
                                            if (val == 'reject') {
                                              return const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              );
                                            }

                                            // 🔥 CEK: apakah semua step sebelumnya sudah approved?
                                            bool previousApproved = true;

                                            for (int i = 1; i < index; i++) {
                                              final prevVal = getApprovalValue(
                                                leave,
                                                i,
                                              );

                                              if (prevVal == null ||
                                                  prevVal == 'reject') {
                                                previousApproved = false;
                                                break;
                                              }
                                            }

                                            // ⏳ kalau belum waktunya (step sebelumnya belum selesai)
                                            if (!previousApproved) {
                                              return const Icon(
                                                Icons.hourglass_empty,
                                                color: Colors.grey,
                                              );
                                            }

                                            // ⏳ kalau step ini belum di-acc
                                            if (val == null) {
                                              return const Icon(
                                                Icons.hourglass_empty,
                                                color: Colors.grey,
                                              );
                                            }

                                            // ✅ baru boleh hijau
                                            return const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            );
                                          }

                                          // ================== CURRENT STEP ==================
                                          int getCurrentStep(
                                            ReqLeaveModel leave,
                                          ) {
                                            if (leave.parentId == "3") {
                                              final skipStore =
                                                  leave.levelId == "19" ||
                                                  leave.levelId == "20";

                                              if (skipStore) {
                                                if (leave.acc2 == null)
                                                  return 0;
                                                if (leave.acc3 == null)
                                                  return 1;
                                                if (leave.acc4 == null)
                                                  return 2;
                                                return 3;
                                              } else {
                                                if (leave.acc1 == null)
                                                  return 0;
                                                if (leave.acc2 == null)
                                                  return 1;
                                                if (leave.acc3 == null)
                                                  return 2;
                                                if (leave.acc4 == null)
                                                  return 3;
                                                return 4;
                                              }
                                            }

                                            // 🔥 FIX NON PARENT 3
                                            if (leave.acc2 == null) return 0;
                                            if (leave.acc4 == null) return 1;
                                            return 2;
                                          }

                                          final nodeTitles = getNodeTitles(
                                            leave,
                                          );
                                          final totalSteps = nodeTitles.length;

                                          final currentStep = getCurrentStep(
                                            leave,
                                          );
                                          final safeStep =
                                              currentStep >= totalSteps
                                                  ? totalSteps - 1
                                                  : currentStep;

                                          final controller =
                                              StepProgressController(
                                                initialStep: safeStep,
                                                totalSteps: totalSteps,
                                              );
                                          final leaveStats = getStepStatus(
                                            leave,
                                          );
                                          final color = getStatusColor(
                                            leaveStats,
                                          );

                                          return ExpansionTileItem(
                                            key: Key(
                                              'leave_tile_$i',
                                            ), // key unik per item penting!
                                            controlAffinity:
                                                ListTileControlAffinity
                                                    .trailing,
                                            tilePadding:
                                                const EdgeInsets.fromLTRB(
                                                  8,
                                                  2,
                                                  8,
                                                  2,
                                                ),
                                            childrenPadding:
                                                const EdgeInsets.fromLTRB(
                                                  8,
                                                  2,
                                                  8,
                                                  2,
                                                ),
                                            isHasBottomBorder: true,
                                            isHasTopBorder: true,
                                            isHasLeftBorder: true,
                                            isHasRightBorder: true,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            backgroundColor:
                                                isDark
                                                    ? Theme.of(
                                                      context,
                                                    ).cardColor
                                                    : Colors.white,
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Iconsax
                                                          .calendar_1_outline,
                                                      color: Colors.blue,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      '${FormatWaktu.formatShortEng(tanggal: DateTime.parse(leave.tgl1!))} - ${FormatWaktu.formatShortEng(tanggal: DateTime.parse(leave.tgl2!))}',
                                                      style: titleTextStyle
                                                          .copyWith(
                                                            fontSize: 15,
                                                            color: Colors.blue,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  leave.jenisCuti!,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    // color:
                                                    // isDark
                                                    //     ? Colors.grey
                                                    //     : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    leaveStats == "pending"
                                                        ? Colors.amber
                                                            .withOpacity(.1)
                                                        : leaveStats ==
                                                            "approved"
                                                        ? Colors.green
                                                            .withOpacity(.1)
                                                        : red!.withOpacity(.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                leaveStats.toUpperCase(),
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            children: [
                                              const SizedBox(height: 15),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                      text:
                                                          'Saya yang bertanda tangan dibawah ini:\n',
                                                    ),
                                                    const TextSpan(
                                                      text: 'Nama    : ',
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${leave.nama!.capitalize}\n',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: 'Jabatan : ',
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${leave.namaLevel!.capitalize}\n\n',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text:
                                                          'Hendak mengajukan permohonan cuti ',
                                                    ),
                                                    TextSpan(
                                                      text: leave.jenisCuti,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text:
                                                          '\nuntuk jangka waktu ',
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          // '${DateTime.parse(leave.tgl2!).difference(DateTime.parse(leave.tgl1!)).inDays} hari,',
                                                          '${leave.jumlahCuti} Hari',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' terhitung dari ',
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          FormatWaktu.formatIndo(
                                                            tanggal:
                                                                DateTime.parse(
                                                                  leave.tgl1!,
                                                                ),
                                                          ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' sampai ',
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          FormatWaktu.formatIndo(
                                                            tanggal:
                                                                DateTime.parse(
                                                                  leave.tgl2!,
                                                                ),
                                                          ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ), // default style
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Alasan cuti:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(leave.alasan!),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Alamat selama cuti:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(leave.alamat!),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Telp / WhatsApp aktif:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(leave.telp!),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'File terlampir',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              leave.attachFile == null ||
                                                      leave.attachFile!.isEmpty
                                                  ? const Text('-')
                                                  : InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Dialog(
                                                            backgroundColor:
                                                                Colors.black,
                                                            insetPadding:
                                                                const EdgeInsets.all(
                                                                  0,
                                                                ),
                                                            child: GestureDetector(
                                                              onTap:
                                                                  () =>
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop(),
                                                              child: PhotoView(
                                                                imageProvider:
                                                                    NetworkImage(
                                                                      '${ServiceApi().baseUrl}${leave.attachFile!}',
                                                                    ),
                                                                backgroundDecoration:
                                                                    const BoxDecoration(
                                                                      color:
                                                                          Colors
                                                                              .black,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: const Text(
                                                      'show file',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                              const SizedBox(height: 10),
                                              StepProgress(
                                                totalSteps: totalSteps,
                                                controller: controller,
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                nodeTitles: nodeTitles,
                                                nodeIconBuilder: (index, _) {
                                                  final bgColor = getStepColor(
                                                    leave,
                                                    index,
                                                  );
                                                  final icon = buildStepIcon(
                                                    leave,
                                                    index,
                                                  );
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: bgColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    // padding: const EdgeInsets.all(6),
                                                    child: icon,
                                                  );
                                                },
                                                theme:
                                                    const StepProgressThemeData(
                                                      lineLabelAlignment:
                                                          Alignment
                                                              .bottomCenter,
                                                      stepLineSpacing: 9,
                                                      stepLineStyle:
                                                          StepLineStyle(
                                                            lineThickness: 3,
                                                            borderRadius:
                                                                Radius.circular(
                                                                  4,
                                                                ),
                                                          ),
                                                      defaultForegroundColor:
                                                          Colors.grey,
                                                      activeForegroundColor:
                                                          Colors.green,
                                                      enableRippleEffect: true,
                                                      lineLabelStyle:
                                                          StepLabelStyle(
                                                            labelAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                          ),
                                                    ),
                                                onStepChanged: (index) {},
                                                onStepNodeTapped: (index) {},
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder:
            (context) => ContainerMainColor(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              radius: 30,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                onPressed: () {
                  final userData = auth.logUser.value;
                  bottomSearchLive(context, isDark, userData, leaveC);
                },
                child: Icon(
                  Icons.manage_search_outlined,
                  color: isDark ? Colors.blue : Colors.white,
                ),
              ),
            ),
      ),
    );
  }
}
