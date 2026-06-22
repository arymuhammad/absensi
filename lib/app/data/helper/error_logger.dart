import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ErrorLogger {
  static Future<void> save(String error, String stack) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/error_log.txt');

      const maxLogSize = 5 * 1024 * 1024; // 5 MB

      // Reset jika lebih dari 5 MB
      if (await file.exists()) {
        final size = await file.length();

        if (size > maxLogSize) {
          await file.writeAsString('');
        }
      }

      final log = '''

        =========================
        ${DateTime.now()}

        ERROR:
        $error

        STACK:
        $stack

        =========================

        ''';

      await file.writeAsString(log, mode: FileMode.append);
    } catch (_) {}
  }

  static Future<File> getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();

    return File('${dir.path}/error_log.txt');
  }

  static Future<void> shareLog() async {
    final original = await getLogFile();

    if (!await original.exists()) {
      throw Exception('Log file not found');
    }

    final tempDir = await getTemporaryDirectory();

    final tempFile = File(
      '${tempDir.path}/error_log_${DateTime.now().millisecondsSinceEpoch}.txt',
    );

    await tempFile.writeAsString(await original.readAsString());

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          text: 'Error Log Aplikasi',
          subject: 'Error Log',
        ),
      );
    } finally {
      // selalu cleanup temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
