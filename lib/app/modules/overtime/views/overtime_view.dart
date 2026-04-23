import 'package:absensi/app/modules/shared/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/helper/app_colors.dart';
import '../../shared/date_picker.dart';
import '../../shared/time_picker.dart';
import '../controllers/overtime_controller.dart';

class OvertimeView extends GetView<OvertimeController> {
  OvertimeView({super.key});
  final ctrl = Get.put(OvertimeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Overtime'),
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
      body: const Center(
        child: Text('OvertimeView is working', style: TextStyle(fontSize: 20)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showForm(context, ctrl);
        },
        child: Icon(Icons.pending_actions),
      ),
    );
  }
}

showForm(BuildContext context, OvertimeController ctrl) {
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
                    label: 'Check In',
                    jam: '',
                    info: '',
                  ),
                ),
                SizedBox(
                  width: Get.mediaQuery.size.width / 2.2,
                  child: CsTimePicker(
                    controller: ctrl.clockOut,
                    label: 'Check Out',
                    jam: '',
                    info: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            CsTextField(
              controller: ctrl.remark,
              label: 'Remark',
              isDark: isDark,
            ),
          ],
        ),
      ),
    ),
  );
}
