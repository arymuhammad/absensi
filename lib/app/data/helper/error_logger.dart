import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ErrorLogger {
  static Future<void> save(String error, String stack) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/error_log.txt');

      const maxLogSize = 10 * 1024 * 1024; // 10 MB

      // Reset jika lebih dari 10 MB
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
    final file = await getLogFile();

    if (!await file.exists()) {
      throw Exception('Log file not found');
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Error Log Aplikasi',
        subject: 'Error Log',
      ),
    );
  }
}
