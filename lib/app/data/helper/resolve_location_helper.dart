import '../../modules/absen/controllers/absen_controller.dart';
import '../model/login_model.dart';

String resolveVisitLocation(Data dataUser, AbsenController controller) {
  final mode = controller.optVisitSelected.value;

  if (mode == "Store Visit") {
    final cabang = controller.selectedCabangVisit.value;

    if (cabang.trim().isNotEmpty) {
      return cabang;
    }

    return dataUser.kodeCabang ?? "";
  }

  final rnd = controller.rndLoc.text.trim();

  if (rnd.isNotEmpty) {
    return rnd;
  }

  return "";
}
