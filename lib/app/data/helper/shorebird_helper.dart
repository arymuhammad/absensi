import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdHelper {
  ShorebirdHelper._();

  static final ShorebirdUpdater updater = ShorebirdUpdater();

  static Future<bool> checkForUpdate() async {
    try {
      if (!updater.isAvailable) {
        debugPrint("Shorebird unavailable");
        return false;
      }

      final status = await updater.checkForUpdate();

      debugPrint("Shorebird status: $status");

      if (status == UpdateStatus.outdated) {
        await updater.update();

        debugPrint("Patch downloaded");
        showToast("Patch downloaded");
        return true;
      }

      debugPrint("Already latest");
      return false;
    } catch (e, s) {
      debugPrint("Shorebird error: $e");
      debugPrint("$s");
      showToast("Shorebird error: $e\n$s");
      return false;
    }
  }
}
