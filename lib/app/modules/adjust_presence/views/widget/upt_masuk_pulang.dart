import 'package:absensi/app/data/model/req_app_model.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:absensi/app/modules/shared/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:step_progress/step_progress.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../../data/helper/const.dart';
import '../../../../data/helper/convert_time.dart';
import '../../../../data/helper/helper_ui.dart';
import '../../../../services/service_api.dart';
import '../../../login/controllers/login_controller.dart';
import '../../../shared/elevated_button.dart';

class UptMasukPulang extends StatelessWidget {
  UptMasukPulang({super.key, required this.data, required this.isInbox});
  final ReqApp data;
  final bool isInbox;
  final auth = Get.find<LoginController>();
  final adjCtrl = Get.put(AdjustPresenceController());
  final homeC = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    // final dataUser = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final levelId = dataUser.level;

    // ================== STEP CONFIG ==================
    List<String> getNodeTitles(ReqApp data) {
      final dataUser = auth.logUser.value;
      // if (leave.parentId == "3") {
      final skipStore = dataUser.level == "19" || dataUser.level == "20";

      if (skipStore) {
        return ['Apply', 'Area Manager', 'Ops', 'HR'];
      }

      return ['Apply', 'Store Manager', 'Area Manager', 'Ops', 'HR'];
      // }

      // return ['Apply', 'Store Manager', 'Area Manager', 'HR'];
    }

    // ================== APPROVAL MAPPING ==================
    String? getApprovalValue(ReqApp data, int index) {
      final dataUser = auth.logUser.value;
      // if (data.parentId == "3") {
      final skipStore = dataUser.level == "19" || dataUser.level == "20";

      if (skipStore) {
        switch (index) {
          case 1:
            return data.acc2;
          case 2:
            return data.acc3;
          case 3:
            return data.acc4;
          default:
            return null;
        }
      } else {
        switch (index) {
          case 1:
            return data.acc1;
          case 2:
            return data.acc2;
          case 3:
            return data.acc3;
          case 4:
            return data.acc4;
          default:
            return null;
        }
      }
      // }

      // 🔥 INI YANG DIPERBAIKI
      // selain parentId 3 → hanya pakai acc2 & acc4
      // switch (index) {
      //   case 1:
      //     return data.acc2; // atasan
      //   case 2:
      //     return data.acc4; // HR
      //   default:
      //     return null;
      // }
    }

    // ================== STATUS ==================
    // String getStepStatus(ReqApp data) {
    //   final dataUser = auth.logUser.value;
    //   bool isEmpty(String? val) => val == null || val.isEmpty;

    //   // 🔴 reject tetap global
    //   if (data.acc1 == 'reject' ||
    //       data.acc2 == 'reject' ||
    //       data.acc3 == 'reject' ||
    //       data.acc4 == 'reject') {
    //     return "rejected";
    //   }

    //   // ======================
    //   // 🔥 KHUSUS PARENT 3
    //   // ======================
    //   // if (data.parentId == "3") {
    //   final skipStore = dataUser.level == "19" || dataUser.level == "20";

    //   if (skipStore) {
    //     // acc2 → acc3 → acc4
    //     if (isEmpty(data.acc2) || isEmpty(data.acc3) || isEmpty(data.acc4)) {
    //       return "pending";
    //     }
    //   } else {
    //     // acc1 → acc2 → acc3 → acc4
    //     if (isEmpty(data.acc1) ||
    //         isEmpty(data.acc2) ||
    //         isEmpty(data.acc3) ||
    //         isEmpty(data.acc4)) {
    //       return "pending";
    //     }
    //   }

    //   return "approved";
    //   // }

    //   // ======================
    //   // 🔥 SEMUA PARENT LAIN
    //   // ======================
    //   // Apply → Atasan → HR
    //   // 👉 acc2 & acc4 doang
    //   // if (isEmpty(data.acc2) || isEmpty(data.acc4)) {
    //   //   return "pending";
    //   // }

    //   // return "approved";
    // }

    // ================== HELPER ==================
    bool isEmptyApproval(String? val) {
      return val == null || val.isEmpty || val == 'null';
    }

    // ================== COLOR ==================
    Color getStepColor(ReqApp data, int index) {
      final val = getApprovalValue(data, index);

      if (index == 0) return Colors.green;

      bool previousApproved = true;

      for (int i = 1; i < index; i++) {
        final prevVal = getApprovalValue(data, i);

        if (isEmptyApproval(prevVal) || prevVal == 'reject') {
          previousApproved = false;
          break;
        }
      }

      if (val == 'reject') return red!;

      if (!previousApproved || isEmptyApproval(val)) {
        return Colors.grey;
      }

      return Colors.green;
    }

    // ================== ICON ==================
    Widget buildStepIcon(ReqApp data, int index) {
      if (index == 0) {
        return const Icon(Icons.check, color: Colors.white, size: 18);
      }

      final val = getApprovalValue(data, index);

      // ❌ reject
      if (val == 'reject') {
        return const Icon(Icons.close, color: Colors.white, size: 18);
      }

      // 🔥 cek step sebelumnya
      bool previousApproved = true;

      for (int i = 1; i < index; i++) {
        final prevVal = getApprovalValue(data, i);

        if (isEmptyApproval(prevVal) || prevVal == 'reject') {
          previousApproved = false;
          break;
        }
      }

      // ⏳ belum waktunya
      if (!previousApproved) {
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
      }

      // ⏳ belum approve
      if (isEmptyApproval(val)) {
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
      }

      // ✅ approved
      return const Icon(Icons.check, color: Colors.white, size: 18);
    }

    // ================== CURRENT STEP ==================
    int getCurrentStep(ReqApp data) {
      final dataUser = auth.logUser.value;
      final skipStore = dataUser.level == "19" || dataUser.level == "20";

      if (skipStore) {
        if (isEmptyApproval(data.acc2)) return 0;
        if (isEmptyApproval(data.acc3)) return 1;
        if (isEmptyApproval(data.acc4)) return 2;
        return 3;
      } else {
        if (isEmptyApproval(data.acc1)) return 0;
        if (isEmptyApproval(data.acc2)) return 1;
        if (isEmptyApproval(data.acc3)) return 2;
        if (isEmptyApproval(data.acc4)) return 3;
        return 4;
      }
    }

    final nodeTitles = getNodeTitles(data);
    final totalSteps = nodeTitles.length;

    final currentStep = getCurrentStep(data);
    final safeStep = currentStep >= totalSteps ? totalSteps - 1 : currentStep;

    final controller = StepProgressController(
      initialStep: safeStep,
      totalSteps: totalSteps,
    );
    // final leaveStats = getStepStatus(data);
    // print(data.statusExcep);
    // final color = getStatusColor(leaveStats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STATUS', style: subtitleTextStyle),
                Text(
                  data.status!.replaceAll('_', ' ').toUpperCase(),
                  style: titleTextStyle.copyWith(fontSize: 14),
                ),
                Row(
                  children: [
                    const Icon(Iconsax.clock_outline),
                    const SizedBox(width: 5),
                    Text(
                      data.status == "update_masuk" ||
                              data.status == "update_masuk_cst"
                          ? data.jamAbsenMasuk!
                          : data.jamAbsenPulang!,
                      style: titleTextStyle,
                    ),
                  ],
                ),
                Visibility(
                  visible:
                      data.status == "update_masuk" ||
                              data.status == "update_masuk_cst"
                          ? false
                          : true,
                  child: Row(
                    children: [
                      const Icon(Iconsax.calendar_2_outline),
                      const SizedBox(width: 5),
                      Text(data.tglPulang!, style: titleTextStyle),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: WidgetZoom(
                heroAnimationTag:
                    data.status == "update_masuk" ||
                            data.status == "update_masuk_cst"
                        ? 'fotoMasuk'
                        : 'fotoPulang',
                zoomWidget: Image.network(
                  '${ServiceApi().baseUrl}${data.status == "update_masuk" || data.status == "update_masuk_cst" ? data.fotoMasuk : data.fotoPulang}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Alasan Perubahan Data', style: titleTextStyle),
        Text(data.alasan!, style: subtitleTextStyle),
        const SizedBox(height: 10),
        Obx(() {
          final dataUser = auth.logUser.value;
          return Visibility(
            visible:
                data.statusExcep == "pending" &&
                        data.keterangan == "" &&
                        ([
                          '1',
                          '17',
                          '18',
                          '19',
                          '20',
                          '39',
                          '26',
                          '96',
                        ]).contains(dataUser.level)
                    ? true
                    : false,
            child: SizedBox(
              height: 45,
              child: CsTextField(
                enabled: true,
                controller: adjCtrl.keteranganApp,
                label: 'Keterangan',
                isDark: isDark,
              ),
            ),
          );
        }),
        const SizedBox(height: 5),
        Visibility(
          visible: data.statusExcep == "reject" ? true : false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Keterangan', style: titleTextStyle.copyWith(fontSize: 18)),
              Text(data.keterangan!, style: subtitleTextStyle),
            ],
          ),
        ),

        // const Divider(
        //   thickness: 2,
        // ),
        const SizedBox(height: 5),
        Obx(() {
          final dataUser = auth.logUser.value;

          return Visibility(
            visible:
                !([
                      '1',
                      '17',
                      '18',
                      '19',
                      '20',
                      '39',
                      '26',
                      '96',
                    ]).contains(dataUser.level)
                    ? true
                    : false,
            child: StepProgress(
              totalSteps: totalSteps,
              controller: controller,
              padding: const EdgeInsets.all(10),
              nodeTitles: nodeTitles,
              nodeIconBuilder: (index, _) {
                final bgColor = getStepColor(data, index);
                final icon = buildStepIcon(data, index);
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
                lineLabelAlignment: Alignment.bottomCenter,
                stepLineSpacing: 9,
                stepLineStyle: StepLineStyle(
                  lineThickness: 3,
                  borderRadius: Radius.circular(4),
                ),
                defaultForegroundColor: Colors.grey,
                activeForegroundColor: Colors.green,
                enableRippleEffect: true,
                lineLabelStyle: StepLabelStyle(
                  labelAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
              onStepChanged: (index) {},
              onStepNodeTapped: (index) {},
            ),
          );
        }),
        Obx(() {
          final dataUser = auth.logUser.value;
          return Visibility(
            visible:
                data.statusExcep == "pending" &&
                        ([
                          '1',
                          '17',
                          '18',
                          '19',
                          '20',
                          '39',
                          '26',
                          '96',
                        ]).contains(dataUser.level)
                    ? true
                    : false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CsElevatedButton(
                  fontsize: 15,
                  label: 'Accept',
                  color: Colors.greenAccent[700]!,
                  onPressed: () {
                    final dataUser = auth.logUser.value;
                    var dataUptApp = {
                      {
                            "1": "acc_4",
                            "17": "acc_4",
                            "18": "acc_4",
                            "39": "acc_4",
                            "96": "acc_3",
                            "26": "acc_2",
                            "19": "acc_1",
                            "20": "acc_1",
                          }[dataUser.level]!:
                          "approved",
                      "uid": data.id,
                      "level": dataUser.level,
                      "keterangan":
                          data.keterangan ?? adjCtrl.keteranganApp.text,
                      "id_user": data.idUser,
                      "tgl_masuk": data.tglMasuk,
                      "status": data.status,
                    };
                    /////////
                    var keyJamAbsen = "";
                    var keyFotoAbsen = "";
                    if (data.status == "update_masuk" ||
                        data.status == "update_masuk_cst") {
                      keyJamAbsen = "jam_absen_masuk";
                      keyFotoAbsen = "foto_masuk";
                    } else {
                      keyJamAbsen = "jam_absen_pulang";
                      keyFotoAbsen = "foto_pulang";
                    }
                    //////////
                    var dataUptAbs = {
                      "status": data.status,
                      "id_user": data.idUser,
                      "tgl_masuk": data.tglMasuk,
                      keyJamAbsen:
                          (data.status == "update_masuk" ||
                                      data.status == "update_masuk_cst"
                                  ? data.jamAbsenMasuk
                                  : data.jamAbsenPulang)
                              .to24Hour(),
                      keyFotoAbsen:
                          data.status == "update_masuk" ||
                                  data.status == "update_masuk_cst"
                              ? data.fotoMasuk
                              : data.fotoPulang,
                      "tgl_pulang": data.tglPulang,
                      "lat_out": data.latOut,
                      "long_out": data.longOut,
                      "device_info2": data.devInfo,
                      // 🔥 tambahan khusus
                      if (data.status == "update_masuk_cst") ...{
                        "jam_masuk": data.jamMasuk,
                        "jam_pulang": data.jamPulang,
                      },
                    };
                    adjCtrl.appAbs(dataUptApp, dataUptAbs, isInbox);
                    homeC.getPendingAdj(
                      idUser: dataUser.id!,
                      idCabang: dataUser.kodeCabang!,
                      level: dataUser.level!,
                    );

                    // ignore: invalid_use_of_protected_member
                    homeC.refresh();
                  },
                ),
                const SizedBox(width: 5),
                CsElevatedButton(
                  fontsize: 15,
                  label: 'Reject',
                  color: Colors.redAccent[700]!,
                  onPressed: () {
                    final dataUser = auth.logUser.value;
                    var dataUptApp = {
                      {
                            "1": "acc_4",
                            "17": "acc_4",
                            "18": "acc_4",
                            "39": "acc_4",
                            "96": "acc_3",
                            "26": "acc_2",
                            "19": "acc_1",
                            "20": "acc_1",
                          }[dataUser.level]!:
                          "reject",
                      "uid": data.id,
                      "level": dataUser.level,
                      "keterangan":
                          data.keterangan ?? adjCtrl.keteranganApp.text,
                      "id_user": data.idUser,
                      "tgl_masuk": data.tglMasuk,
                      "status": data.status,
                    };
                    adjCtrl.appAbs(dataUptApp, {}, isInbox);
                    homeC.getPendingAdj(
                      idUser: dataUser.id!,
                      idCabang: dataUser.kodeCabang!,
                      level: dataUser.level!,
                    );

                    // ignore: invalid_use_of_protected_member
                    homeC.refresh();
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
