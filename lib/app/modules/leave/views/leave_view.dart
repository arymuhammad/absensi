import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/modules/leave/views/widget/leave_remove.dart';
import 'package:absensi/app/modules/leave/views/widget/show_attachment.dart';
import 'package:absensi/app/modules/leave/views/widget/step_config.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:startapp_sdk/startapp.dart';
import 'package:step_progress/step_progress.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/helper_ui.dart';
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
              leaveC.selectedLeaveType.value = ""; // RESET LEAVE TYPE ON INIT

              final list = ['Cuti', 'Replacement Off'];
              Get.defaultDialog(
                title: 'Leave',
                content: DropdownButtonFormField(
                  items:
                      list
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == 'Replacement Off') {
                      leaveC.selectedLeaveType.value = 'Lainnya';
                    } else {
                      leaveC.selectedLeaveType.value = 'Hak Cuti Tahunan';
                    }
                    // print(leaveC.selectedLeaveType.value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pilih salah satu',
                  ),
                ),
                radius: 8,
                actions: [
                  Obx(
                    () => OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(
                          color:
                              leaveC.selectedLeaveType.value.isEmpty
                                  ? Colors.grey
                                  : Colors.blue,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                      ),
                      onPressed:
                          leaveC.selectedLeaveType.value.isEmpty ||
                                  leaveC.selectedLeaveType.value == ""
                              ? null
                              : () async {
                                if (leaveC.selectedLeaveType.value ==
                                    'Lainnya') {
                                  closeLoading();
                                  final newUserData = auth.logUser.value;
                                  //=============
                                  // Generate UID
                                  //=============
                                  leaveC.generateUid();
                                  leaveC.selectedLeaveType.value = "Lainnya";
                                  leaveC.selectedLeave.value =
                                      "Replacement Off";
                                  // leaveC.remainDays.value = 1;
                                  leaveC.amtTkn.text = "1";

                                  Get.bottomSheet(
                                    LeaveAddSheet(
                                      userData: newUserData,
                                      isActive: false,
                                    ),
                                    isScrollControlled: true,
                                    isDismissible: false,
                                    // enableDrag: false,
                                  );
                                } else {
                                  closeLoading();

                                  BuildContext? dialogContext;

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) {
                                      dialogContext = ctx;

                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );
                                  // leaveC.getLeaveList();
                                  await leaveC.leaveBalanceCheck(userData);

                                  if (dialogContext != null) {
                                    Navigator.of(dialogContext!).pop();
                                  }

                                  final newUserData = auth.logUser.value;

                                  leaveC.generateUid();

                                  if (newUserData.leaveBalance == "0") {
                                    showToast(
                                      "Saldo Cuti Anda Habis\nTidak dapat mengajukan cuti",
                                    );

                                    return;
                                  }
                                  leaveC.selectedLeaveType.value = "";
                                  leaveC.selectedLeave.value = "";
                                  leaveC.amtTkn.text = "0";
                                  Get.bottomSheet(
                                    LeaveAddSheet(
                                      userData: newUserData,
                                      isActive: true,
                                    ),
                                    isScrollControlled: true,
                                    isDismissible: false,
                                    // enableDrag: false,
                                  );
                                }
                              },
                      child: Obx(
                        () => Text(
                          leaveC.selectedLeaveType.value == 'Lainnya'
                              ? 'Lanjut'
                              : 'Cek saldo cuti',
                          // style: const TextStyle(color: AppColors.contentColorWhite),
                        ),
                      ),
                    ),
                  ),
                ],
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

                                          final nodeTitles = StepConfig()
                                              .getNodeTitles(leave);
                                          final totalSteps = nodeTitles.length;

                                          final currentStep = StepConfig()
                                              .getCurrentStep(leave);
                                          final safeStep =
                                              currentStep >= totalSteps
                                                  ? totalSteps - 1
                                                  : currentStep;

                                          final controller =
                                              StepProgressController(
                                                initialStep: safeStep,
                                                totalSteps: totalSteps,
                                              );

                                          //=======================================

                                          final DateTime created =
                                              DateTime.parse(leave.tglBuat!);
                                          final DateTime now = DateTime.now();

                                          // Request aktif sampai tanggal 9 bulan berikutnya.
                                          // Expired mulai tanggal 10.
                                          final DateTime expiredAt = DateTime(
                                            created.year,
                                            created.month + 1,
                                            10,
                                          );

                                          final bool isExpired =
                                              !now.isBefore(expiredAt);

                                          //========================================

                                          final leaveStats =
                                              isExpired
                                                  ? 'expired'
                                                  : StepConfig().getStepStatus(
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
                                            trailing: Transform.translate(
                                              offset: const Offset(0, 4),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // STATUS
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: color.withOpacity(
                                                        .1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      leaveStats.toUpperCase(),
                                                      style: TextStyle(
                                                        color: color,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                  // ⋮ HANYA PENDING
                                                  if (leaveStats == "pending")
                                                    liveRemove(
                                                      context,
                                                      'Hapus pengajuan ini',
                                                      'Hapus',
                                                      () =>
                                                          leaveC.deleteLeaveReq(
                                                            leave.uid!,
                                                          ),
                                                    ),
                                                ],
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
                                                          '${leave.nama?.capitalize ?? '-'}\n',
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
                                                          '${leave.namaLevel?.capitalize ?? '-'}\n\n',
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
                                              Text(
                                                leave.alasan?.capitalizeFirst ??
                                                    '-',
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Alamat selama cuti:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                leave.alamat?.capitalizeFirst ??
                                                    '-',
                                              ),
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
                                                      leave.attachFile!
                                                          .trim()
                                                          .isEmpty
                                                  ? const Text('-')
                                                  : InkWell(
                                                    onTap: () {
                                                      showAttchment(
                                                        context,
                                                        leave,
                                                      );
                                                    },
                                                    child: Text(
                                                      leave.attachFile!
                                                              .contains(',')
                                                          ? 'Show ${leave.attachFile!.split(',').length} Files'
                                                          : 'Show File',
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Diajukan pada',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                FormatWaktu.formatIndoWithTimeStamp(
                                                  tanggal: DateTime.parse(
                                                    leave.tglBuat!,
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
                                                  final bgColor = StepConfig()
                                                      .getStepColor(
                                                        leave,
                                                        index,
                                                      );
                                                  final icon = StepConfig()
                                                      .buildStepIcon(
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
