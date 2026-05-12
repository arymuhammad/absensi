import 'dart:io';
import 'dart:math' as math;

import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/approval/widget/bottom_search_overtime.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/shared/elevated_button.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helper/app_colors.dart';
import '../../../data/helper/helper_ui.dart';
import '../../../data/helper/loading_platform.dart';
import '../../../services/service_api.dart';
import '../../overtime/controllers/overtime_controller.dart';
import '../../shared/container_main_color.dart';

class ReqOvertimeView extends StatelessWidget {
  ReqOvertimeView({super.key});
  final ctrl = Get.find<OvertimeController>();
  final auth = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomMaterialIndicator(
        onRefresh: () async {
          final userData = auth.logUser.value;
          await ctrl.getListOvertime(
            idUser: userData.id!,
            level: userData.level!,
            type: "",
            status: "pending",
          );
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
          if (ctrl.isLoading.value) {
            return Center(child: platFormDevice());
          }
          final list = ctrl.filteredList;

          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Card(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Icon(Icons.inbox, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Center(child: Text('No overtime request')),
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Card(
              child: ListView.builder(
                itemCount: list.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = list[index];
                  final date = DateTime.parse(item.initDate!);
                  final status = item.status ?? 'pending';
                  final color = getStatusColor(status);

                  final duration = getDuration(
                    item.start ?? '',
                    item.end ?? '',
                  );

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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 🔹 AVATAR
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
                                                item.name![0],
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                              : null,
                                    ),
                                    const SizedBox(height: 5),
                                    Column(
                                      children: [
                                        Text(
                                          date.day.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          monthName(date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 12),

                                /// 🔹 CONTENT
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// 🔸 NAME + STATUS
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.name ?? '-',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                        ],
                                      ),

                                      const SizedBox(height: 5),

                                      /// 🔸 STORE LOC
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.store_mall_directory_rounded,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.branchName!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 5),

                                      /// 🔸 TIME
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('${item.start} - ${item.end}'),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      /// 🔸 DURATION
                                      Text(
                                        'Durasi: $duration',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.remark ?? '-',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CsElevatedButton(
                                  color: red!,
                                  fontsize: 15,
                                  label: 'Reject',
                                  onPressed: () {
                                    final userData = auth.logUser.value;
                                    ctrl.reject(
                                      level: userData.level!,
                                      idUser: userData.id!,
                                      idOvt: item.id!,
                                      date1: item.initDate!,
                                      date2: item.endDate!,
                                    );
                                  },
                                ),
                                const SizedBox(width: 5),
                                CsElevatedButton(
                                  color: green!,
                                  fontsize: 15,
                                  label: 'Accept',
                                  onPressed: () {
                                    final userData = auth.logUser.value;
                                    ctrl.accept(
                                      level: userData.level!,
                                      idUser: userData.id!,
                                      idOvt: item.id!,
                                      date1: item.initDate!,
                                      date2: item.endDate!,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
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
                  bottomSearchOvertime(context, isDark, userData, ctrl);
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
