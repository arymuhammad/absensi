import 'dart:async';

import 'package:absensi/app/data/helper/calendar_badge.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:step_progress/step_progress.dart';

import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/helper/helper_ui.dart';
import '../../../data/helper/loading_platform.dart';
import '../../../data/model/permission_model.dart';
import '../../../services/service_api.dart';
import '../../login/controllers/login_controller.dart';
import '../../shared/container_main_color.dart';
import '../controllers/izin_controller.dart';
import 'widget/permission_add.dart';
import 'widget/permission_tab.dart';

class IzinView extends GetView<IzinController> {
  IzinView({super.key});

  final ctrl = Get.put(IzinController());
  final auth = Get.find<LoginController>();
  // final Rxn<DateTimeRange> pickedRange = Rxn<DateTimeRange>();
  // final Rx<DateTime> pickedMonth = DateTime.now().obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Izin'),
            GestureDetector(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: DateTimeRange(
                    start: ctrl.pickedMonth.value,
                    end: ctrl.pickedMonth.value,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme:
                            isDark
                                ? const ColorScheme.dark(
                                  primary:
                                      Colors
                                          .blueAccent, // 🔥 warna selection (range highlight)
                                  onPrimary:
                                      Colors
                                          .white, // 🔥 warna text di tanggal terpilih
                                  secondary:
                                      Colors
                                          .blueAccent, // 🔥 untuk hover / range
                                  onSurface: Colors.white, // text normal
                                  surface: Color(0xFF121212),
                                )
                                : ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                  surface:
                                      Theme.of(context).secondaryHeaderColor,
                                ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (range != null) {
                  final userData = auth.logUser.value;
                  loadingDialog("memuat data...", "");
                  await ctrl.getPermissionList(
                    idUser: userData.id!,
                    kodeCabang: userData.kodeCabang!,
                    parentId: userData.parentId!,
                    level: userData.level!,
                    type: "",
                    status: "",
                    date1: DateFormat('yyyy-MM-dd').format(range.start),
                    date2: DateFormat('yyyy-MM-dd').format(range.end),
                  );
                  Get.back();

                  ctrl.pickedRange.value = range;
                }
              },
              child: const Icon(CupertinoIcons.calendar, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
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
      body: CustomMaterialIndicator(
        onRefresh: () async {
          final userData = auth.logUser.value;
          ctrl.isLoading.value = true;
          await ctrl.getPermissionList(
            idUser: userData.id!,
            kodeCabang: userData.kodeCabang!,
            parentId: userData.parentId!,
            level: userData.level!,
            type: "",
            status: "",
            date1:
                ctrl.pickedRange.value == null
                    ? ctrl.initDate
                    : DateFormat(
                      'yyyy-MM-dd',
                    ).format(ctrl.pickedRange.value!.start),
            date2:
                ctrl.pickedRange.value == null
                    ? ctrl.endDate
                    : DateFormat(
                      'yyyy-MM-dd',
                    ).format(ctrl.pickedRange.value!.end),
          );
          showToast('Page Refreshed');
        },
        child: Column(
          children: [
            PermissionTab(selected: ctrl.selectedStatus),
            searchField(isDark, ctrl),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return Center(child: platFormDevice());
                }
                final list = ctrl.filteredList;

                if (list.isEmpty) {
                  return const Center(child: Text('Data not found'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    // final date = DateTime.parse(item.tanggalMulai!);
                    final status = item.status ?? 'pending';
                    final color = getStatusColor(status);

                    String getLastNote() {
                      if ((item.noteAcc4 ?? '').isNotEmpty) {
                        return item.noteAcc4!;
                      }
                      if ((item.noteAcc3 ?? '').isNotEmpty) {
                        return item.noteAcc3!;
                      }
                      if ((item.noteAcc2 ?? '').isNotEmpty) {
                        return item.noteAcc2!;
                      }
                      if ((item.noteAcc1 ?? '').isNotEmpty) {
                        return item.noteAcc1!;
                      }
                      return '-';
                    }

                    //=======================//
                    //||                   ||//
                    //=======================//
                    int getTotalSteps() {
                      if (item.level == "19" ||
                          item.level == "20" ||
                          item.level == "59") {
                        return 4;
                      }
                      return 5;
                    }

                    int totalSteps = getTotalSteps();
                    List<String> nodeTitlesFull = const [
                      'Apply',
                      'Store Manager',
                      'Area Manager',
                      'Ops',
                      'HR',
                    ];

                    // Node titles untuk 3 steps (kurangi 1 step, misalnya tanpa step terakhir "HR")
                    List<String> nodeTitles4Steps = const [
                      'Apply',
                      // 'Store Manager',
                      'Area Manager',
                      'Ops',
                      'HR',
                    ];

                    List<String> getNodeTitles() {
                      if (item.level == "19" ||
                          item.level == "20" ||
                          item.level == "59") {
                        // Level 19 di parent 3; 3 steps tapi sM seperti contoh kamu
                        return nodeTitles4Steps;
                      } else {
                        // parentId 3 tapi levelId bukan yg disebut di atas, pakai 4 steps
                        return nodeTitlesFull;
                      }
                    }

                    int getCurrentStep(PermissionModel ovr, int totalSteps) {
                      int step = 0;

                      if (totalSteps == 5) {
                        if (ovr.acc4 != null) {
                          step = 4;
                        } else if (ovr.acc3 != null) {
                          step = 3;
                        } else if (ovr.acc2 != null) {
                          step = 2;
                        } else if (ovr.acc1 != null) {
                          step = 1;
                        }
                      } else {
                        if (ovr.acc4 != null) {
                          step = 3;
                        } else if (ovr.acc3 != null) {
                          step = 2;
                        } else if (ovr.acc2 != null) {
                          step = 1;
                        }
                      }

                      return step;
                    }

                    final int currentStep = getCurrentStep(item, totalSteps);
                    // print(stepInfo['currentStep']);
                    final controller = StepProgressController(
                      initialStep: currentStep,
                      totalSteps: totalSteps,
                    );

                    String? getValByStep(int index) {
                      if (totalSteps == 5) {
                        // normal (5 step)
                        switch (index) {
                          case 1:
                            return item.acc1;
                          case 2:
                            return item.acc2;
                          case 3:
                            return item.acc3;
                          case 4:
                            return item.acc4;
                          default:
                            return null;
                        }
                      } else {
                        // totalSteps == 4 (skip acc1)
                        switch (index) {
                          case 1:
                            return item.acc2;
                          case 2:
                            return item.acc3;
                          case 3:
                            return item.acc4;
                          default:
                            return null;
                        }
                      }
                    }

                    Color getBackgroundColorForStep(int index) {
                      if (index == 0) return Colors.green;

                      final val = getValByStep(index);

                      // ❗ PRIORITAS 1: CANCEL
                      if (val == "reject") return red!;

                      if (index > currentStep) return Colors.grey;

                      if (index == currentStep && val == null) {
                        return Colors.grey;
                      }

                      return Colors.green;
                    }

                    Widget iconBuilder(int index, int completedStepIndex) {
                      if (index == 0) {
                        return const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        );
                      }

                      final val = getValByStep(index);

                      // 🔴 PRIORITAS: cancel dulu
                      if (val == "reject") {
                        return const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        );
                      }

                      // ⛔ BELUM SAMPAI STEP -> JANGAN CHECKLIST
                      if (index > currentStep) {
                        return const Icon(
                          Icons.hourglass_empty,
                          color: Colors.grey,
                        );
                      }

                      // ⏳ BELUM ADA ACTION
                      if (val == null) {
                        return const Icon(
                          Icons.hourglass_empty,
                          color: Colors.grey,
                        );
                      }

                      // ✅ SUDAH APPROVE
                      return const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      );
                    }

                    // final leaveStats =
                    //     (currentStep == 0)
                    //         ? "Waiting Approval"
                    //         : getOvrtStatusForStep(currentStep);
                    final nodeTitles = getNodeTitles().sublist(0, totalSteps);
                    //==================================
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              ///========================
                              /// HEADER
                              ///========================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Avatar
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: color.withOpacity(.2),
                                        backgroundImage:
                                            item.photo != null &&
                                                    item.photo!.isNotEmpty
                                                ? NetworkImage(
                                                  '${ServiceApi().baseUrl}${item.photo}',
                                                )
                                                : null,
                                        child:
                                            item.photo == null ||
                                                    item.photo!.isEmpty
                                                ? Text(
                                                  item.nama![0],
                                                  style: TextStyle(
                                                    color: color,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                                : null,
                                      ),
                                      const SizedBox(height: 5),
                                      calendarBadge(
                                        startDate: DateTime.parse(
                                          item.tanggalMulai!,
                                        ),
                                        endDate: DateTime.parse(
                                          item.tanggalSelesai!,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 12),

                                  /// CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// Nama + Status
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.nama?.capitalize ?? '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            /// STATUS
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
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
                                                    status.toUpperCase(),
                                                    style: TextStyle(
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                // POPUP BUTTON
                                                if (item.status == "pending")
                                                  PopupMenuButton<String>(
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                    position:
                                                        PopupMenuPosition.under,
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(
                                                        2,
                                                      ),
                                                      child: Icon(
                                                        Icons.more_vert,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    onSelected: (value) {
                                                      if (value == 'delete') {
                                                        final userData =
                                                            auth.logUser.value;

                                                        ctrl.delete(
                                                          item.id,
                                                          userData.id!,
                                                          userData.parentId!,
                                                          userData.level!,
                                                          userData.kodeCabang!,
                                                        );
                                                      }
                                                    },
                                                    itemBuilder:
                                                        (context) => const [
                                                          PopupMenuItem(
                                                            value: 'delete',
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.delete,
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text('Hapus'),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        /// Cabang
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons
                                                  .store_mall_directory_rounded,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item.namaCabang?.capitalize ??
                                                    '-',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 5),

                                        /// Alasan
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.health_and_safety_outlined,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item.alasan?.capitalizeFirst ??
                                                    '-',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 5),

                                        item.lampiran!.trim().isEmpty
                                            ? const Text('-')
                                            : InkWell(
                                              onTap: () {
                                                final files = parseLampiran(
                                                  item.lampiran,
                                                );
                                                if (files.isEmpty) {
                                                  showToast(
                                                    "Tidak ada lampiran",
                                                  );
                                                  return;
                                                }

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => Dialog(
                                                        backgroundColor:
                                                            Colors.black,
                                                        insetPadding:
                                                            EdgeInsets.zero,
                                                        child: Stack(
                                                          children: [
                                                            PageView.builder(
                                                              itemCount:
                                                                  files.length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                // print(
                                                                //   '${ServiceApi().baseUrl}${files[index]}',
                                                                // );
                                                                return PhotoView(
                                                                  imageProvider:
                                                                      NetworkImage(
                                                                        '${ServiceApi().baseUrl}${files[index]}',
                                                                      ),
                                                                  backgroundDecoration:
                                                                      const BoxDecoration(
                                                                        color:
                                                                            Colors.black,
                                                                      ),
                                                                  errorBuilder: (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) {
                                                                    return const Center(
                                                                      child: Text(
                                                                        'Gagal memuat gambar',
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),

                                                            Positioned(
                                                              top: 35,
                                                              right: 20,
                                                              child: CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black54,
                                                                child: IconButton(
                                                                  icon: const Icon(
                                                                    Icons.close,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                  onPressed:
                                                                      () =>
                                                                          Get.back(),
                                                                ),
                                                              ),
                                                            ),

                                                            if (files.length >
                                                                1)
                                                              Positioned(
                                                                bottom: 20,
                                                                left: 0,
                                                                right: 0,
                                                                child: Center(
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          6,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Colors
                                                                              .black54,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            20,
                                                                          ),
                                                                    ),
                                                                    child: Text(
                                                                      'Geser untuk melihat ${files.length} lampiran',
                                                                      style: const TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                );
                                              },
                                              child: Text(
                                                item.lampiran!.contains(',')
                                                    ? 'Show ${item.lampiran!.split(',').length} Files'
                                                    : 'Show File',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),

                                        const SizedBox(height: 6),

                                        const Text(
                                          'Diajukan pada',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),

                                        Text(
                                          FormatWaktu.formatIndoWithTimeStamp(
                                            tanggal: DateTime.parse(
                                              item.createdAt!,
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        if (item.status != "pending") ...[
                                          const SizedBox(height: 10),
                                          const Divider(),
                                          const SizedBox(height: 5),

                                          const Text(
                                            "Note",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          Text(
                                            getLastNote().capitalize ?? '-',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // const SizedBox(height: 12),

                              ///========================
                              /// STEP PROGRESS
                              ///========================
                              StepProgress(
                                totalSteps: totalSteps,
                                controller: controller,
                                padding: const EdgeInsets.all(10),
                                nodeTitles: nodeTitles,
                                nodeIconBuilder: (index, completedStepIndex) {
                                  final bgColor = getBackgroundColorForStep(
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
                                onStepChanged: (_) {},
                                onStepNodeTapped: (_) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: ContainerMainColor(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        radius: 30,
        child: FloatingActionButton(
          onPressed: () {
            final userData = auth.logUser.value;
            permissionAdd(context, ctrl, userData);
          },
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.health_and_safety_rounded,
            color: isDark ? Colors.blue : Colors.white,
          ),
        ),
      ),
    );
  }
}

Widget searchField(bool isDark, IzinController ctrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: CupertinoTextField(
      controller: ctrl.searchC,
      placeholder: 'Search overtime...',
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      prefix: const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(
          CupertinoIcons.search,
          size: 18,
          color: CupertinoColors.systemGrey,
        ),
      ),
      suffix: Obx(() {
        if (ctrl.searchQuery.value.isEmpty) return const SizedBox();
        return GestureDetector(
          onTap: () {
            ctrl.searchC.clear();
            ctrl.searchQuery.value = '';
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.clear_circled_solid,
              size: 18,
              color: CupertinoColors.systemGrey,
            ),
          ),
        );
      }),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      onChanged: (val) {
        ctrl.debounce?.cancel();
        ctrl.debounce = Timer(const Duration(milliseconds: 300), () {
          ctrl.searchQuery.value = val;
        });
      },
    ),
  );
}
