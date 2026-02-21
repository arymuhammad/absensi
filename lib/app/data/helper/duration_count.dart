
String hitungDurasiFull({
  required String? tglMasuk,
  required String? jamMasuk,
  required String? tglPulang,
  required String? jamPulang,
}) {
  if (tglMasuk == null ||
      jamMasuk == null ||
      jamMasuk.isEmpty ||
      jamPulang == null ||
      jamPulang.isEmpty ||
      tglPulang == null) {
    return '- j - m';
  }

  try {
    final masuk = DateTime.parse('$tglMasuk $jamMasuk');
    final pulang = DateTime.parse('$tglPulang $jamPulang');
    final diff = pulang.difference(masuk);

    return '${diff.inHours}j ${diff.inMinutes % 60}m';
  } catch (_) {
    return '- j - m';
  }
}

String hitungIn({required String? jamMasuk, required String? jamAbsenMasuk}) {
  if (jamMasuk == null ||
      jamMasuk.isEmpty ||
      jamAbsenMasuk == null ||
      jamAbsenMasuk.isEmpty) {
    return '';
  }

  try {
    final jmasuk = parseTimeToday(jamMasuk);
    final jamasuk = parseTimeToday(jamAbsenMasuk);
    final diff = jmasuk.difference(jamasuk);
    final minutes = diff.inMinutes;

    if (minutes == 0) {
      return '';
    }

    if (minutes > 0) {
      return '(+$minutes m)';
    }

    return '($minutes m)';
  } catch (_) {
    return '';
  }
}

String hitungOut({
  required String? tglMasuk,
  required String? jamMasuk,
  required String? tglPulang,
  required String? jamPulang,
}) {
  if (tglMasuk == null ||
      jamMasuk == null ||
      jamMasuk.isEmpty ||
      jamPulang == null ||
      jamPulang.isEmpty ||
      tglPulang == null) {
    return '';
  }

  try {
    final masuk = DateTime.parse('$tglMasuk $jamMasuk');
    final pulang = DateTime.parse('$tglPulang $jamPulang');

    final totalMinutes = pulang.difference(masuk).inMinutes;

    const normalWorkMinutes = 8 * 60;

    final selisih = totalMinutes - normalWorkMinutes;

    if (selisih == 0) {
      return '';
    }

    if (selisih > 0) {
      return '(+$selisih m)'; // lembur
    }

    return '($selisih m)'; // otomatis minus
  } catch (_) {
    return '';
  }
}

DateTime parseTimeToday(String time) {
  final parts = time.split(":");
  final now = DateTime.now();

  return DateTime(
    now.year,
    now.month,
    now.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}
