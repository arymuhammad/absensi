import 'package:absensi/app/data/helper/db_result.dart';
import 'package:get/get.dart';

import '../../../../data/model/login_model.dart';
import '../../controllers/absen_controller.dart';
import '../widget/check_in.dart';
import '../widget/check_out.dart';
import '../widget/visit_in.dart';
import '../widget/visit_out.dart';

class AbsenUseCase {
  Future<DbResult> handleAction({
    required Data data,
    required AbsenController controller,
  }) async {
    try {
      await controller.initTime();

      if (controller.isTimeUntrusted.value) {
        return DbResult.error("Jam tidak valid!");
      }

      final sts = controller.stsAbsenSelected.value;
      if (sts.isEmpty) {
        return DbResult.error("Please select check in / out first");
      }

      /// ================= VISIT =================
      if (data.visit == "1") {
        final visitType = controller.optVisitSelected.value;

        if (visitType.isEmpty) {
          return DbResult.error("Please select RND / Visit first");
        }

        if (visitType == "Research and Development" &&
            controller.rndLoc.text.isEmpty) {
          return DbResult.error("Please fill in the location");
        }

        if (sts == "Check In") {
          await visitIn(
            dataUser: data,
            latitude: controller.latFromGps.value,
            longitude: controller.longFromGps.value,
          );
        } else {
          await visitOut(
            dataUser: data,
            latitude: controller.latFromGps.value,
            longitude: controller.longFromGps.value,
          );
        }
      }

      /// ================= ABSEN =================
      else {
        if (sts == "Check In" && controller.selectedShift.isEmpty) {
          return DbResult.error(
              "Please select absence shift first");
        }

        if (sts == "Check In") {
          await checkIn(
            data,
            controller.latFromGps.value,
            controller.longFromGps.value,
          );
        } else {
          await checkOut(
            data,
            controller.latFromGps.value,
            controller.longFromGps.value,
          );
        }
      }

      return DbResult.success();
    } catch (e) {
      return DbResult.error("Terjadi kesalahan: ${e.toString()}");
    }
  }
}