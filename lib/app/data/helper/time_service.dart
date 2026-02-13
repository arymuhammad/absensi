import 'dart:io';
import 'package:http/http.dart' as http;

Future<DateTime?> getServerTimeLocal() async {
  final res = await http.get(
    Uri.parse("http://103.156.15.61/api-absensi"),
  );

  final dateHeader = res.headers['date'];
  if (dateHeader == null) return null;

  // parse GMT → UTC
  final utcTime = HttpDate.parse(dateHeader);

  // convert ke timezone device
  final localTime = utcTime.toLocal();

  return localTime;
}
