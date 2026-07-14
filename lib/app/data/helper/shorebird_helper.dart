import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdHelper {
  ShorebirdHelper._();

  static final ShorebirdUpdater updater = ShorebirdUpdater();

  static bool _checking = false;

  /// Mengecek status patch.
  /// Tidak melakukan download.
  static Future<UpdateStatus?> checkStatus() async {
    if (_checking) {
      debugPrint("Shorebird: checking already in progress");
      return null;
    }

    _checking = true;

    try {
      if (!updater.isAvailable) {
        debugPrint("Shorebird unavailable");
        return null;
      }

      final status = await updater.checkForUpdate();

      debugPrint("Shorebird status: $status");

      return status;
    } catch (e, s) {
      debugPrint("Shorebird error: $e");
      debugPrint("$s");
      return null;
    } finally {
      _checking = false;
    }
  }

  /// Download patch.
  /// Panggil hanya jika status == UpdateStatus.outdated.
  static Future<bool> downloadPatch() async {
    try {
      await updater.update();

      debugPrint("Patch downloaded");
      // showToast("Patch downloaded");

      return true;
    } catch (e, s) {
      debugPrint("Shorebird update error: $e");
      debugPrint("$s");

      if (e.toString().contains("already in progress")) {
        showToast("Patch sedang diunduh...");
      } else {
        showToast("Gagal mengunduh patch.");
      }

      return false;
    }
  }

  static Future<String> currentPatchVersion() async {
    try {
      if (!updater.isAvailable) {
        return "Shorebird unavailable";
      }

      final patch = await updater.readCurrentPatch();

      if (patch == null) {
        return "Base Release";
      }

      return "Patch #${patch.number}";
      // atau:
      // return "Patch ${patch.number} (${patch.hash.substring(0, 8)})";
    } catch (e) {
      return "Unknown";
    }
  }
}
