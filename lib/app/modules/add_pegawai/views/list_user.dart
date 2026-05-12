import 'dart:io';

import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/shared/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/add_pegawai_controller.dart';

class ListUserView extends StatelessWidget {
  ListUserView({super.key});
  final ctrl = Get.find<AddPegawaiController>();
  final auth = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final userData = auth.logUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('List User', style: titleTextStyle.copyWith(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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
      body: Obx(() {
        final data = ctrl.filterDataUser;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CsTextField(
                enabled: true,
                label: 'Search user',
                controller: ctrl.filterUser,
                icon: const Icon(Iconsax.user_search_bold),
                maxLines: 1,
                onChanged: (val) => ctrl.searchKeyword.value = val,
                isDark: isDark,
              ),
            ),
            Expanded(
              child:
                  ctrl.isLoading.value
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Platform.isAndroid
                                ? const CircularProgressIndicator()
                                : const CircularProgressIndicator(),
                            const SizedBox(height: 5),
                            const Text('Memuat data user'),
                          ],
                        ),
                      )
                      : Padding(
                         padding: const EdgeInsets.fromLTRB(
                                      11.0,
                                      0.0,
                                      11.0,
                                      11.0,
                                    ),
                        child: Card(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (c, i) {
                              final user = data[i];
                          
                              return ListTile(
                                title: Text(user.nama!.capitalize!),
                                subtitle: Text(user.namaLevel!.capitalize!),
                                trailing: Switch(
                                  value: user.isActive!,
                                  onChanged: (value) async {
                                    // print(value);
                                    user.isActive = value;
                                    loadingDialog("${!user.isActive! ?'disable':'activate'} user account", "");
                                    await ctrl.updateUsrState(
                                      id: user.id,
                                      active: value,
                                    );
                                    await ctrl.getUser(
                                      userData.kodeCabang!,
                                      userData.parentId!,
                                    );
                                    ctrl.listUser.refresh();
                                    Get.back();
                                  },
                                  activeTrackColor: Colors.lightGreenAccent,
                                  activeColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
            ),
          ],
        );
      }),
    );
  }
}
