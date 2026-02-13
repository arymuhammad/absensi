String hitungDurasi({
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
