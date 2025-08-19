import 'package:intl/intl.dart';

class FormatWaktu {
  static formatBulan({required String tanggal}) {
    return DateFormat(
      'MMMM',
    ).format(DateTime.parse(tanggal)).toUpperCase().toString();
  }
  static formatShortMonth({required String tanggal}) {
    return DateFormat(
      'MMM',
    ).format(DateTime.parse(tanggal)).toUpperCase().toString();
  }

  static formatTanggal({required String tanggal}) {
    return DateFormat('dd').format(DateTime.parse(tanggal)).toString();
  }

  static formatHariId({required String tanggal}) {
    return DateFormat.EEEE('id').format(DateTime.parse(tanggal)).toString();
  }
  
  static formatHariEn({required String tanggal}) {
    return DateFormat("EE").format(DateTime.parse(tanggal)).toString();
  }

  static DateTime formatJamMenit({required String jamMenit}) {
    return DateFormat("HH:mm").parse(jamMenit);
  }

  static formatIndo({required DateTime tanggal}) {
    return DateFormat.yMMMMEEEEd('id_ID').format(tanggal).toString();
  }
  
  static formatEng({required DateTime tanggal}) {
    return DateFormat("EEEE, d MMMM yyyy").format(tanggal).toString();
  }
  
  static formatShortEng({required DateTime tanggal}) {
    return DateFormat("d MMM yyyy").format(tanggal).toString();
  }
}
