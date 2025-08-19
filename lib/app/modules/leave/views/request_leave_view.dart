import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/shared/elevated_button.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../data/helper/app_colors.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/model/leave_model.dart';
import '../../../data/model/login_model.dart';
import '../controllers/leave_controller.dart';

class RequestLeaveView extends GetView<LeaveController> {
  RequestLeaveView({super.key, this.userData});
  final Data? userData;
  final leaveC = Get.find<LeaveController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Leave',
          style: titleTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.contentColorWhite,
          ),
        ),
        backgroundColor: AppColors.itemsBackground,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () {
              var param = {
                "type": "get_pending_req_leave",
                "kode_cabang": userData!.kodeCabang!,
                "id_user": userData!.id!,
                "level": userData!.level!,
                "parent_id": userData!.parentId!,
              };
              return leaveC.getLeaveReq(param);
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
                              child: Text('Belum ada data pengajuan cuti'),
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
                                var validLevels = ["19", "26", "50", "59"];
                                int getTotalSteps() {
                                  if (leave.parentId == "3" &&
                                      !validLevels.contains(leave.levelId)) {
                                    return 4;
                                  }
                                  return 3;
                                }

                                int totalSteps = getTotalSteps();
                                // Tentukan step aktif (0-based)
                                // String stepLabel = "";

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
                                        if (leave.parentId == "4") {
                                          if (leave.levelId == "43") {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "General Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
                                          } else {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "IT Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
                                          }
                                        } else if (leave.parentId == "5") {
                                          if (leave.levelId == "77") {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "General Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
                                          } else {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "EDITORIAL Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
                                          }
                                        } else if (leave.parentId == "8") {
                                          if (leave.levelId == "18") {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "General Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
                                          } else {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "HRD Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
                                          }
                                        } else if (leave.parentId == "9") {
                                          if (leave.levelId == "41") {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "General Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
                                          } else {
                                            stepLabel =
                                                leave.acc2 == "0" ||
                                                        leave.acc2 == null
                                                    ? "Brand Manager"
                                                    : "HRD";
                                            currentStep =
                                                leave.acc2 == null ? 0 : 1;
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

                                final stepInfo = getStepInfo(leave);
                                final String stepLabel = stepInfo['stepLabel'];
                                final int currentStep = stepInfo['currentStep'];

                                // Fungsi untuk status leave per step index
                                String getLeaveStatusForStep(int stepIndex) {
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
                                  int cancelStep = totalSteps == 4 ? 3 : 2;

                                  if (val == '0' && stepIndex == cancelStep ||
                                      val == '0') {
                                    return "Canceled by";
                                  } else if (val == null ||
                                      stepIndex <= waitLimit) {
                                    return "Waiting Approval";
                                  } else {
                                    return "Approved by";
                                  }
                                }

                                final leaveStats =
                                    (currentStep == 0)
                                        ? "Waiting Approval"
                                        : getLeaveStatusForStep(currentStep);

                                return ExpansionTileItem(
                                  key: Key(
                                    'leave_tile_$i',
                                  ), // key unik per item penting!
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  isHasBottomBorder: true,
                                  isHasTopBorder: true,
                                  isHasLeftBorder: true,
                                  isHasRightBorder: true,
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              leaveStats == "Waiting Approval"
                                                  ? Colors.amber
                                                  : leaveStats == "Approved by"
                                                  ? Colors.green
                                                  : Colors.grey,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          leaveStats == "Waiting Approval"
                                              ? 'Pending'
                                              : leaveStats == "Approved by"
                                              ? 'Approved'
                                              : 'Canceled',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        leave.nama!.capitalize!,
                                        style: titleTextStyle.copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            leave.idUser!,
                                            style: subtitleTextStyle.copyWith(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Text(' - '),
                                          Text(
                                            leave.namaLevel!.capitalize!,
                                            style: subtitleTextStyle.copyWith(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        leave.namaCabang!,
                                        style: subtitleTextStyle.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),

                                      const SizedBox(height: 6),
                                      Text(
                                        leave.jenisCuti!,
                                        style: const TextStyle(
                                          fontSize: 15,
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
                                            text: 'Dengan ini,\nSaya ',
                                          ),
                                          TextSpan(
                                            text: leave.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                ', hendak mengajukan permohonan cuti\n',
                                          ),
                                          TextSpan(
                                            text: leave.jenisCuti,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' untuk jangka waktu ',
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
                                          const TextSpan(text: ' sampai '),
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

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CsElevatedButton(
                                          label: 'Cancel',
                                          color: AppColors.contentColorRed,
                                          fontsize: 15,
                                          onPressed: () {
                                            promptDialog(
                                              context: context,
                                              title: 'KONFIRMASI',
                                              desc: 'Tolak pengajuan ini?',
                                              btnOkOnPress: () async {
                                                var param = {
                                                  "type": "reject",
                                                  "uid": leave.uid!,
                                                  "level": userData!.level,
                                                  "acc_name": userData!.nama,
                                                  "sign": "0",
                                                };
                                                await ServiceApi().leave(param);
                                                var reload = {
                                                  "type":
                                                      "get_pending_req_leave",
                                                  "kode_cabang":
                                                      userData!.kodeCabang!,
                                                  "id_user": userData!.id!,
                                                  "level": userData!.level!,
                                                };
                                                leaveC.isLoading.value = true;
                                                leaveC.getLeaveReq(reload);
                                              },
                                            );
                                          },
                                          size: const Size(double.infinity, 30),
                                        ),
                                        CsElevatedButton(
                                          label: 'Approve',
                                          color:
                                              AppColors.contentColorGreenAccent,
                                          fontsize: 15,
                                          onPressed: () {
                                            signDialog(
                                              context,
                                              userData!,
                                              leave.uid!,
                                            );
                                          },
                                          size: const Size(double.infinity, 30),
                                        ),
                                      ],
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
        ],
      ),
    );
  }

  void signDialog(BuildContext context, Data? userData, String uid) {
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
                    if (leaveC.ctrSign.value.isEmpty) {
                      showToast("Harap buat tanda tangan dahulu");
                    } else {
                      leaveC.approveLeave(context, userData, uid);
                    }
                  },
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
