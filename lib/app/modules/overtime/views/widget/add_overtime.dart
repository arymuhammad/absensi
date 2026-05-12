import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/model/login_model.dart';
import '../../../shared/container_main_color.dart';
import '../../../shared/date_picker.dart';
import '../../../shared/elevated_button.dart';
import '../../../shared/text_field.dart';
import '../../../shared/time_picker.dart';
import '../../controllers/overtime_controller.dart';

addOvertime(BuildContext context, OvertimeController ctrl, Data userData){
  final isDark = Theme.of(context).brightness == Brightness.dark;
  Get.bottomSheet(
    Container(
      height: 250,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.mediaQuery.size.width / 2.2,
                  child: CsTimePicker(
                    controller: ctrl.clockIn,
                    label: 'Start',
                    jam: '',
                    info: '',
                  ),
                ),
                SizedBox(
                  width: Get.mediaQuery.size.width / 2.2,
                  child: CsTimePicker(
                    controller: ctrl.clockOut,
                    label: 'End',
                    jam: '',
                    info: '',
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

                      ctrl.submitOvertime(
                        id: userData.id!,
                        branchCode: userData.kodeCabang!,
                        name: userData.nama!,
                        level: userData.level!,
                        photo: userData.foto!,
                        initDate: ctrl.date1.text,
                        endDate: ctrl.date2.text,
                        start: ctrl.clockIn.text,
                        end: ctrl.clockOut.text,
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
                          ctrl.clockIn.text.isNotEmpty ||
                          ctrl.clockOut.text.isNotEmpty ||
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