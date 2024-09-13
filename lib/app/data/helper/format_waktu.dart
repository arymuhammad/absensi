import 'package:intl/intl.dart';

class FormatWaktu {
  static formatBulan({required String tanggal}) {
    return DateFormat('MMM')
        .format(DateTime.parse(tanggal))
        .toUpperCase()
        .toString();
  }

  static formatTanggal({required String tanggal}) {
    return DateFormat('dd').format(DateTime.parse(tanggal)).toString();
  }

  static formatHari({required String tanggal}) {
    return DateFormat("EEEE", "id_ID")
        .format(DateTime.parse(tanggal))
        .toString();
  }

  static DateTime formatJamMenit({required String jamMenit}) {
    return DateFormat("HH:mm").parse(jamMenit);
  }

  static formatIndo({required DateTime tanggal}) {
    return DateFormat("EEEE, d MMM yyyy", "id_ID").format(tanggal).toString();
  }
}