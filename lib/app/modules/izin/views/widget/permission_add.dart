import 'dart:io';

import 'package:absensi/app/modules/izin/controllers/izin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/model/login_model.dart';
import '../../../shared/container_main_color.dart';
import '../../../shared/date_picker.dart';
import '../../../shared/elevated_button.dart';
import '../../../shared/text_field.dart';

permissionAdd(BuildContext context, IzinController ctrl, Data userData) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  Get.bottomSheet(
    Container(
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? Theme.of(context).cardColor : Colors.grey[300],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.mediaQuery.size.width / 2.2,
                  child: CsDatePicker(
                    editable: true,
                    controller: ctrl.date1,
                    label: 'Start Date',
                  ),
                ),
                SizedBox(
                  width: Get.mediaQuery.size.width / 2.2,
                  child: CsDatePicker(
                    editable: true,
                    controller: ctrl.date2,
                    label: 'End Date',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
            CsTextField(
              enabled: true,
              controller: ctrl.remark,
              label: 'Remark',
              icon: const Icon(Icons.edit_note_sharp),
              maxLines: 1,
              isDark: isDark,
            ),
            const SizedBox(height: 5),
            //attach file
            Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () => ctrl.uploadFile(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GetBuilder<IzinController>(
                          builder: (c) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...List.generate(c.images.length, (index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 65,
                                        height: 65,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(c.images[index].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            c.images.removeAt(index);
                                            c.update();
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }),

                                if (c.images.length < 3)
                                  InkWell(
                                    onTap: c.uploadFile,
                                    child: Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo),
                                          Text("Upload"),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                        const SizedBox(height: 5),
                        const Text('*Upload file pendukung (Max 3 file)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ContainerMainColor(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  radius: 30,
                  child: CsElevatedButton(
                    color: Colors.transparent,
                    fontsize: 18,
                    label: 'Send Request',
                    onPressed: () {
                      if (!ctrl.canSubmit) {
                        failedDialog(
                          Get.overlayContext!,
                          'Error',
                          'Harap lengkapi semua data',
                        );
                        return;
                      }

                      ctrl.submitPermission(
                        id: userData.id!,
                        parentId: userData.parentId!,
                        branchCode: userData.kodeCabang!,
                        name: userData.nama!,
                        photo: userData.foto!,
                        level: userData.level!,
                        initDate: ctrl.date1.text,
                        endDate: ctrl.date2.text,
                        remarks: ctrl.remark.text,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 5),
                ContainerMainColor(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  radius: 30,
                  child: CsElevatedButton(
                    color: Colors.transparent,
                    fontsize: 18,
                    label: 'Cancel',
                    onPressed: () {
                      if (ctrl.date1.text.isNotEmpty ||
                          ctrl.date2.text.isNotEmpty ||
                          ctrl.remark.text.isNotEmpty) {
                        promptDialog(
                          context: Get.overlayContext!,
                          desc: 'Batalkan pengajuan ini?',
                          title: 'Warning',
                          btnOkOnPress: ctrl.resetForm,
                        );
                      } else {
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
