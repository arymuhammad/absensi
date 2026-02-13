import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:step_progress/step_progress.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../data/helper/const.dart';
import '../../../data/model/leave_model.dart';
import '../controllers/leave_controller.dart';
import 'widget/leave_add.dart';

class LeaveView extends GetView<LeaveController> {
  LeaveView({super.key, this.userData});
  final Data? userData;

  final leaveC = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
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
              loadingDialog('Mengecek sisa saldo cuti kamu', '');
              await leaveC.leaveBalanceCheck(userData!);
              Get.back();
              userData!.leaveBalance == "0"
                  ? showToast(
                    "Saldo Cuti Anda Habis\nAnda tidak dapat mengajukan permohonan cuti",
                  )
                  : Get.to(() {
                    leaveC.generateUid();

                    return LeaveAdd(userData: userData);
                  }, transition: Transition.cupertino);
            },
            icon: const Icon(Icons.format_list_bulleted_add),
          ),
        ],
        flexibleSpace: Container(decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),),
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
                      "id_user": userData!.id!,
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
                              padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                children: [
                                  ExpansionTileGroup(
                                    toggleType: ToggleType.expandOnlyCurrent,
                                    spaceBetweenItem: 5,
                                    children: List.generate(leaveC.listLeaveReq.length, (
                                      i,
                                    ) {
                                      final leave = leaveC.listLeaveReq[i];
                                      // Fungsi untuk menghitung totalSteps
                                      var validLevels = [
                                        "19",
                                        "26",
                                        "50",
                                        "59",
                                      ];
                                      int getTotalSteps() {
                                        //                                         print('parentId: "${leave.parentId}"');
                                        // print('levelId: "${leave.levelId}", isInValidLevels: ${validLevels.contains(leave.levelId)}');
                                        if (leave.parentId == "3" &&
                                            !validLevels.contains(
                                              leave.levelId,
                                            )) {
                                          return 4;
                                        }
                                        return 3;
                                      }

                                      int totalSteps = getTotalSteps();
                                      // Data base nodeTitles full (4 steps)
                                      List<String> nodeTitlesFull = const [
                                        'Apply',
                                        'Store Manager',
                                        'Area Manager',
                                        'HRD',
                                      ];

                                      // Node titles untuk 3 steps (kurangi 1 step, misalnya tanpa step terakhir "HR")
                                      List<String> nodeTitles3Steps = const [
                                        'Apply',
                                        // 'Store Manager',
                                        'Area Manager',
                                        'HRD',
                                      ];

                                      // Fungsi untuk dapatkan nodeTitles berdasarkan kondisi user dan totalSteps
                                      List<String> getNodeTitles() {
                                        if (leave.parentId == "2") {
                                          return [
                                            'Apply',
                                            leave.levelId == "29" ||
                                                    leave.levelId == "80" ||
                                                    leave.levelId == "60"
                                                ? 'General Manager'
                                                : 'Operational Manager',
                                            'HRD',
                                          ];
                                        } else if (leave.parentId == "3") {
                                          if (leave.levelId == "19" ||
                                              leave.levelId == "50" ||
                                              leave.levelId == "59") {
                                            // Level 19 di parent 3; 3 steps tapi sM seperti contoh kamu
                                            return nodeTitles3Steps;
                                          } else if (leave.levelId == "26") {
                                            return const [
                                              'Apply',
                                              'Operational Manager',
                                              'HRD',
                                            ];
                                            // }
                                            // else if (userData!.levelId == "50" ||
                                            //     userData!.levelId == "59") {
                                            //   // Tambahkan jika ingin memperhatikan levelId 50 dan 59
                                            //   return nodeTitlesFull; // misal 4 steps
                                          } else {
                                            // parentId 3 tapi levelId bukan yg disebut di atas, pakai 4 steps
                                            return nodeTitlesFull;
                                          }
                                        } else if (leave.parentId == "4") {
                                          // Parent 4 misal default sD atau hD

                                          return [
                                            'Apply',
                                            leave.parentId == "4" &&
                                                    leave.levelId != '43'
                                                ? 'IT Manager'
                                                : 'General Manager',
                                            'HRD',
                                          ];
                                        } else if (leave.parentId == "5") {
                                          // Contoh untuk parent 5 bisa disesuaikan
                                          return [
                                            'Apply',
                                            leave.parentId == "5" &&
                                                    leave.levelId != '77'
                                                ? 'EDITORIAL Manager'
                                                : 'General Manager',
                                            'HRD',
                                          ];
                                        } else if (leave.parentId == "8") {
                                          return [
                                            'Apply',
                                            leave.parentId == "8" &&
                                                    leave.levelId != '18'
                                                ? 'HRD Manager'
                                                : 'General Manager',
                                            'HRD',
                                          ];
                                        } else if (leave.parentId == "9") {
                                          return [
                                            'Apply',
                                            leave.parentId == "9" &&
                                                    leave.levelId != '41'
                                                ? 'Brand Manager'
                                                : 'General Manager',
                                            'HRD',
                                          ];
                                        } else {
                                          // Default fallback
                                          return nodeTitlesFull;
                                        }
                                      }

                                      // Fungsi untuk mendapatkan step label dan currentStep
                                      Map<String, dynamic> getStepInfo(
                                        LeaveModel leave,
                                      ) {
                                        String stepLabel = "";
                                        int currentStep = 0;

                                        // Kondisi untuk initial step (step 0)
                                        if (leave.acc1 == null &&
                                            leave.acc2 == null &&
                                            leave.acc3 == null) {
                                          if (leave.parentId == "3" &&
                                              leave.levelId != "19" &&
                                              leave.levelId != "26" &&
                                              leave.levelId != "50" &&
                                              leave.levelId != "59") {
                                            stepLabel = "Store Manager";
                                          } else if (leave.parentId == "3" &&
                                              (leave.levelId == "19" ||
                                                  leave.levelId == "59")) {
                                            stepLabel = "Area Manager";
                                          } else if (leave.parentId == "3" &&
                                              (leave.levelId == "26" ||
                                                  leave.levelId == "50")) {
                                            stepLabel = "Operational Manager";
                                          } else if (leave.parentId == "4" &&
                                              leave.levelId != "43") {
                                            stepLabel = "IT Manager";
                                          } else if (leave.parentId == "4" &&
                                              leave.levelId == "43") {
                                            stepLabel = "General Manager";
                                          } else if (leave.parentId == "5" &&
                                              leave.levelId != "77") {
                                            stepLabel = "EDITORIAL Manager";
                                          } else if (leave.parentId == "5" &&
                                              leave.levelId == "77") {
                                            stepLabel = "General Manager";
                                          } else if (leave.parentId == "8" &&
                                              leave.levelId != "18") {
                                            stepLabel = "HRD Manager";
                                          } else if (leave.parentId == "8" &&
                                              leave.levelId == "18") {
                                            stepLabel = "General Manager";
                                          } else if (leave.parentId == "9" &&
                                              leave.levelId != "41") {
                                            stepLabel = "Brand Manager";
                                          } else if (leave.parentId == "9" &&
                                              leave.levelId == "41") {
                                            stepLabel = "General Manager";
                                          } else {
                                            stepLabel = "";
                                          }
                                          currentStep = 0;
                                        }
                                        // Kondisi step 1 jika totalSteps == 4, step 1 dan 2 masih ada
                                        else if (totalSteps == 4) {
                                          if (leave.acc2 == null &&
                                              leave.acc3 == null) {
                                            stepLabel =
                                                leave.acc1 == "0"
                                                    ? "Store Manager"
                                                    : "Area Manager";
                                            currentStep = 1;
                                          } else if (leave.acc3 == null) {
                                            stepLabel =
                                                leave.acc2 == "0"
                                                    ? "Area Manager"
                                                    : "HRD";
                                            currentStep = 2;
                                          } else {
                                            stepLabel = "HRD";
                                            currentStep = 3;
                                          }
                                        }
                                        // Kondisi jika totalSteps == 3, hanya ada 3 step (step 0,1,2)
                                        else {
                                          if (totalSteps == 3) {
                                            if (leave.acc3 == null) {
                                              // Step 1 - berdasarkan acc2 dan userData
                                              if (leave.parentId == "2") {
                                                if (leave.levelId == "29" ||
                                                    leave.levelId == "80" ||
                                                    leave.levelId == "60") {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "General Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                } else {
                                                  // print(leave.levelId);
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "Operational Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                }
                                              } else if (leave.parentId ==
                                                  "3") {
                                                if (leave.levelId == "19" ||
                                                    leave.levelId == "59") {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "Area Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                } else if (leave.levelId ==
                                                        "26" ||
                                                    leave.levelId == "50") {
                                                  // print(leave.levelId);
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "Operational Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                }
                                              } else if (leave.parentId ==
                                                  "4") {
                                                if (leave.levelId == "43") {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "General Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                } else {
                                                  // print(leave.levelId);
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "IT Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                }
                                              } else if (leave.parentId ==
                                                  "5") {
                                                if (leave.levelId == "77") {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "General Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                } else {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "EDITORIAL Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                }
                                              } else if (leave.parentId ==
                                                  "8") {
                                                if (leave.levelId == "18") {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "General Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                } else {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "HRD Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                }
                                              } else if (leave.parentId ==
                                                  "9") {
                                                if (leave.levelId == "41") {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "General Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                } else {
                                                  stepLabel =
                                                      leave.acc2 == "0" ||
                                                              leave.acc2 == null
                                                          ? "Brand Manager"
                                                          : "HRD";
                                                  currentStep =
                                                      leave.acc2 == null
                                                          ? 0
                                                          : 1;
                                                }
                                              } else {
                                                stepLabel = "";
                                              }
                                            } else {
                                              // Step 2 - acc3 sudah ada, label HRD

                                              stepLabel = "HRD";
                                              currentStep = 2;
                                            }
                                          }
                                        }

                                        return {
                                          'stepLabel': stepLabel,
                                          'currentStep': currentStep,
                                        };
                                      }

                                      // Penggunaan di dalam List.generate
                                      // final leave = leaveC.listLeaveReq[i];
                                      final stepInfo = getStepInfo(leave);
                                      final String stepLabel =
                                          stepInfo['stepLabel'];
                                      final int currentStep =
                                          stepInfo['currentStep'];

                                      final controller = StepProgressController(
                                        initialStep: currentStep,
                                        totalSteps: totalSteps,
                                      );

                                      // Fungsi untuk status leave per step index
                                      String getLeaveStatusForStep(
                                        int stepIndex,
                                      ) {
                                        if (stepIndex >= totalSteps) {
                                          // Step tidak valid, bisa return status default atau kosong
                                          return "";
                                        }

                                        String? val;
                                        if (totalSteps == 4) {
                                          // Mapping for 4 steps: acc1, acc2, acc3
                                          switch (stepIndex) {
                                            case 1:
                                              val = leave.acc1;
                                              break;
                                            case 2:
                                              val = leave.acc2;
                                              break;
                                            case 3:
                                              val = leave.acc3;
                                              break;
                                            default:
                                              val =
                                                  null; // step 0 or other - no approval
                                              break;
                                          }
                                        } else if (totalSteps == 3) {
                                          // Mapping for 3 steps: acc1, acc2 (acc3 tidak digunakan)
                                          switch (stepIndex) {
                                            case 1:
                                              val = leave.acc2;
                                              break;
                                            case 2:
                                              val = leave.acc3;
                                              break;
                                            default:
                                              val =
                                                  null; // step 0 or other - no approval
                                              break;
                                          }
                                        } else {
                                          // fallback, misal totalSteps < 3
                                          val = null;
                                        }
                                        int waitLimit = totalSteps == 4 ? 2 : 1;
                                        int cancelStep =
                                            totalSteps == 4 ? 3 : 2;

                                        if (val == '0' &&
                                                stepIndex == cancelStep ||
                                            val == '0') {
                                          return "Canceled by";
                                        } else if (val == null ||
                                            stepIndex <= waitLimit) {
                                          return "Waiting Approval";
                                        } else {
                                          return "Approved by";
                                        }
                                      }

                                      Color getBackgroundColorForStep(
                                        int index,
                                      ) {
                                        if (index >= totalSteps) {
                                          // misal kembalikan warna abu-abu jika step tidak valid
                                          return Colors.grey;
                                        }

                                        String? val;
                                        if (totalSteps == 4) {
                                          // Mapping for 4 steps: acc1, acc2, acc3
                                          switch (index) {
                                            case 1:
                                              val = leave.acc1;
                                              break;
                                            case 2:
                                              val = leave.acc2;
                                              break;
                                            case 3:
                                              val = leave.acc3;
                                              break;
                                            default:
                                              val =
                                                  null; // step 0 or other - no approval
                                              break;
                                          }
                                        } else if (totalSteps == 3) {
                                          // Mapping for 3 steps: acc1, acc2 (acc3 tidak digunakan)
                                          switch (index) {
                                            case 1:
                                              val = leave.acc2;
                                              break;
                                            case 2:
                                              val = leave.acc3;
                                              break;
                                            default:
                                              val =
                                                  null; // step 0 or other - no approval
                                              break;
                                          }
                                        } else {
                                          // fallback, misal totalSteps < 3
                                          val = null;
                                        }

                                        if (val == '0') {
                                          return red!;
                                        } else if (val == null && index != 0) {
                                          return Colors.grey;
                                        } else {
                                          return Colors.green;
                                        }
                                      }

                                      Widget iconBuilder(
                                        int index,
                                        int completedStepIndex,
                                      ) {
                                        if (index >= totalSteps) {
                                          // Step diluar totalSteps, tampilkan icon waiting
                                          return const Icon(
                                            Icons.hourglass_empty,
                                            color: Colors.grey,
                                          );
                                        }

                                        String? val;

                                        if (totalSteps == 4) {
                                          // Mapping for 4 steps: acc1, acc2, acc3
                                          switch (index) {
                                            case 1:
                                              val = leave.acc1;
                                              break;
                                            case 2:
                                              val = leave.acc2;
                                              break;
                                            case 3:
                                              val = leave.acc3;
                                              break;
                                            default:
                                              val =
                                                  null; // step 0 or other - no approval
                                              break;
                                          }
                                        } else if (totalSteps == 3) {
                                          // Mapping for 3 steps: acc1, acc2 (acc3 tidak digunakan)
                                          switch (index) {
                                            case 1:
                                              val = leave.acc2;
                                              break;
                                            case 2:
                                              val = leave.acc3;
                                              break;
                                            default:
                                              val =
                                                  null; // step 0 or other - no approval
                                              break;
                                          }
                                        } else {
                                          // fallback, misal totalSteps < 3
                                          val = null;
                                        }

                                        // Jika index 0 (initial step), biasanya tidak ada val approval -> tampilkan check (atau sesuai logic)
                                        if (index == 0) {
                                          return const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          );
                                        }

                                        if (val == '0') {
                                          // Approval rejected
                                          return const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          );
                                        } else if (val == null && index != 0) {
                                          // Menunggu approval
                                          return const Icon(
                                            Icons.hourglass_empty,
                                            color: Colors.grey,
                                          );
                                        } else {
                                          // Approval accepted
                                          return const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          );
                                        }
                                      }

                                      final leaveStats =
                                          (currentStep == 0)
                                              ? "Waiting Approval"
                                              : getLeaveStatusForStep(
                                                currentStep,
                                              );
                                      // print('current step: $currentStep');
                                      // final totalSteps = getTotalSteps();
                                      final nodeTitles = getNodeTitles()
                                          .sublist(0, totalSteps);

                                      return ExpansionTileItem(
                                        key: Key(
                                          'leave_tile_$i',
                                        ), // key unik per item penting!
                                        controlAffinity:
                                            ListTileControlAffinity.trailing,
                                        tilePadding: const EdgeInsets.fromLTRB(
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
                                        borderRadius: BorderRadius.circular(5),
                                        backgroundColor: Colors.white,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    leaveStats ==
                                                            "Waiting Approval"
                                                        ? Colors.amber
                                                        : leaveStats ==
                                                            "Approved by"
                                                        ? Colors.green
                                                        : Colors.grey,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topRight: Radius.circular(
                                                        20,
                                                      ),
                                                      bottomRight:
                                                          Radius.circular(20),
                                                    ),
                                              ),
                                              child: Text(
                                                leaveStats == "Waiting Approval"
                                                    ? 'Pending'
                                                    : leaveStats ==
                                                        "Approved by"
                                                    ? 'Approved'
                                                    : 'Canceled',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Iconsax.calendar_1_outline,
                                                  color:
                                                      AppColors.itemsBackground,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${FormatWaktu.formatShortEng(tanggal: DateTime.parse(leave.tgl1!))} - ${FormatWaktu.formatShortEng(tanggal: DateTime.parse(leave.tgl2!))}',
                                                  style: titleTextStyle.copyWith(
                                                    fontSize: 15,
                                                    color:
                                                        AppColors
                                                            .itemsBackground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              leave.jenisCuti!,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              leaveStats,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              stepLabel,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
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
                                                  text: '${leave.nama}\n',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: 'Jabatan : ',
                                                ),
                                                TextSpan(
                                                  text:
                                                      '${leave.namaLevel}\n\n',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text:
                                                      'Hendak mengajukan permohonan cuti ',
                                                ),
                                                TextSpan(
                                                  text: leave.jenisCuti,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: '\nuntuk jangka waktu ',
                                                ),
                                                TextSpan(
                                                  text:
                                                      '${DateTime.parse(leave.tgl2!).difference(DateTime.parse(leave.tgl1!)).inDays + 1} hari,',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: ' terhitung dari ',
                                                ),
                                                TextSpan(
                                                  text: FormatWaktu.formatIndo(
                                                    tanggal: DateTime.parse(
                                                      leave.tgl1!,
                                                    ),
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: ' sampai ',
                                                ),
                                                TextSpan(
                                                  text: FormatWaktu.formatIndo(
                                                    tanggal: DateTime.parse(
                                                      leave.tgl2!,
                                                    ),
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                              style: const TextStyle(
                                                color: Colors.black,
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
                                            'Telp:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(leave.telp!),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Selanjutnya, tugas akan diserahkan kepada:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${leave.userPengganti!}\n${leave.idUserPengganti} - ${leave.levelUserPengganti}',
                                          ),
                                          const SizedBox(height: 15),
                                          StepProgress(
                                            totalSteps: totalSteps,
                                            controller: controller,
                                            padding: const EdgeInsets.all(10),
                                            nodeTitles: nodeTitles,
                                            nodeIconBuilder: (
                                              index,
                                              completedStepIndex,
                                            ) {
                                              final bgColor =
                                                  getBackgroundColorForStep(
                                                    index,
                                                  );
                                              final icon = iconBuilder(
                                                index,
                                                completedStepIndex,
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
                                            theme: const StepProgressThemeData(
                                              lineLabelAlignment:
                                                  Alignment.bottomCenter,
                                              stepLineSpacing: 9,
                                              stepLineStyle: StepLineStyle(
                                                lineThickness: 6,
                                                borderRadius: Radius.circular(
                                                  4,
                                                ),
                                              ),
                                              defaultForegroundColor:
                                                  Colors.grey,
                                              activeForegroundColor:
                                                  Colors.green,
                                              enableRippleEffect: true,
                                              lineLabelStyle: StepLabelStyle(
                                                labelAxisAlignment:
                                                    CrossAxisAlignment.end,
                                              ),
                                            ),
                                            onStepChanged: (index) {},
                                            onStepNodeTapped: (index) {},
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),

          // if (leaveC.bannerAd != null)
          //   Align(
          //     alignment: Alignment.bottomCenter,
          //     child: SizedBox(
          //       width: leaveC.bannerAd!.value.size.width.toDouble(),
          //       height: leaveC.bannerAd!.value.size.height.toDouble(),
          //       child: AdWidget(ad: leaveC.bannerAd!.value),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
