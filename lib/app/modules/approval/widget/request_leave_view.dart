import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/helper_ui.dart';
import 'package:absensi/app/modules/approval/widget/bottom_search_live.dart';
import 'package:absensi/app/modules/shared/elevated_button.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:signature/signature.dart';
import '../../../data/helper/app_colors.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/helper/loading_platform.dart';
import '../../../data/model/login_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../leave/controllers/leave_controller.dart';
import '../../shared/container_main_color.dart';

class RequestLeaveView extends GetView<LeaveController> {
  RequestLeaveView({super.key});

  final auth = Get.find<LoginController>();
  final leaveC = Get.find<LeaveController>();
  final homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          CustomMaterialIndicator(
            onRefresh: () async {
              final userData = auth.logUser.value;
              var param = {
                "type": "get_pending_req_leave",
                "kode_cabang": userData.kodeCabang!,
                "id_user": userData.id!,
                "level": userData.level!,
                "parent_id": userData.parentId!,
              };
              // print(param);
              await leaveC.getLeaveReq(param);
              showToast('Page Refreshed');
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
            child: Obx(() {
              final keyword = homeC.search.value.toLowerCase();

              final filteredList =
                  leaveC.listLeaveReq.where((leave) {
                    return (leave.nama ?? '').toLowerCase().contains(keyword) ||
                        (leave.idUser ?? '').toLowerCase().contains(keyword) ||
                        (leave.namaCabang ?? '').toLowerCase().contains(
                          keyword,
                        ) ||
                        (leave.jenisCuti ?? '').toLowerCase().contains(keyword);
                  }).toList();

              if (leaveC.isLoading.value) {
                return Center(child: platFormDevice());
              }

              if (filteredList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                  child: Card(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        const Icon(Icons.inbox, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Center(child: Text('No leave request')),
                      ],
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ExpansionTileGroup(
                          toggleType: ToggleType.expandOnlyCurrent,
                          spaceBetweenItem: 5,
                          children: List.generate(filteredList.length, (i) {
                            final leave = filteredList[i];
                            final status = leave.status ?? 'pending';

                            final color = getStatusColor(status);

                            return ExpansionTileItem(
                              key: Key(
                                'leave_tile_$i',
                              ), // key unik per item penting!
                              controlAffinity: ListTileControlAffinity.trailing,
                              tilePadding: const EdgeInsets.fromLTRB(
                                8,
                                2,
                                8,
                                2,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
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
                              backgroundColor:
                                  isDark
                                      ? Theme.of(context).cardColor
                                      : Colors.white,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          isDark ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      status == "pending"
                                          ? Colors.amber.withOpacity(.1)
                                          : status == "approved"
                                          ? Colors.green.withOpacity(.1)
                                          : red!.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.toUpperCase(),
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
                                      TextSpan(
                                        text:
                                            'Saya yang bertanda tangan dibawah ini:\n',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Nama    : ',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${leave.nama}\n',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Jabatan : ',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${leave.namaLevel}\n\n',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            'Hendak mengajukan permohonan cuti ',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: leave.jenisCuti,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\nuntuk jangka waktu ',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${DateTime.parse(leave.tgl2!).difference(DateTime.parse(leave.tgl1!)).inDays + 1} hari,',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' terhitung dari ',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: FormatWaktu.formatIndo(
                                          tanggal: DateTime.parse(leave.tgl1!),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' sampai ',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: FormatWaktu.formatIndo(
                                          tanggal: DateTime.parse(leave.tgl2!),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.black,
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(leave.alasan!),
                                const SizedBox(height: 10),
                                const Text(
                                  'Alamat selama cuti:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(leave.alamat!),
                                const SizedBox(height: 10),
                                const Text(
                                  'Telp:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(leave.telp!),
                                const SizedBox(height: 10),
                                const Text(
                                  'File terlampir',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.black,
                                          insetPadding: const EdgeInsets.all(0),
                                          child: GestureDetector(
                                            onTap:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: PhotoView(
                                              imageProvider: NetworkImage(
                                                '${ServiceApi().baseUrl}${leave.attachFile!}',
                                              ),
                                              backgroundDecoration:
                                                  const BoxDecoration(
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'show file',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CsElevatedButton(
                                      label: 'Reject',
                                      color: red!,
                                      fontsize: 15,
                                      onPressed:
                                          status == "approved" ||
                                                  status == "rejected"
                                              ? null
                                              : () {
                                                final userData =
                                                    auth.logUser.value;
                                                promptDialog(
                                                  context: context,
                                                  title: 'Confirm',
                                                  desc: 'Reject this request?',
                                                  btnOkOnPress: () async {
                                                    var param = {
                                                      "type": "reject",
                                                      "uid": leave.uid!,
                                                      "level": userData.level,
                                                      "acc_name": userData.nama,
                                                      "sign": "reject",
                                                    };
                                                    await ServiceApi().reqLeave(
                                                      param,
                                                    );
                                                    var reload = {
                                                      "type":
                                                          "get_pending_req_leave",
                                                      "kode_cabang":
                                                          userData.kodeCabang!,
                                                      "id_user": userData.id!,
                                                      "level": userData.level!,
                                                    };
                                                    leaveC.isLoading.value =
                                                        true;
                                                    leaveC.getLeaveReq(reload);
                                                  },
                                                );
                                              },
                                      size: const Size(double.infinity, 30),
                                    ),
                                    const SizedBox(width: 5),
                                    CsElevatedButton(
                                      label: 'Approve',
                                      color: AppColors.contentColorGreenAccent,
                                      fontsize: 15,
                                      onPressed:
                                          status == "approved" ||
                                                  status == "rejected"
                                              ? null
                                              : () {
                                                final userData =
                                                    auth.logUser.value;
                                                signDialog(
                                                  context,
                                                  userData,
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
                      ),
                    ),
                  ],
                ),
              );
            }),
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
