class SummaryAbsenModel {
  late int? hadir;
  late int? tepatWaktu;
  late int? telat;

  SummaryAbsenModel({this.hadir, this.tepatWaktu, this.telat});

  factory SummaryAbsenModel.fromJson(Map<String, dynamic> json) {
    return SummaryAbsenModel(
      hadir: int.tryParse(json['hadir']?.toString() ?? '0') ?? 0,
      tepatWaktu: int.tryParse(json['tepat_waktu']?.toString() ?? '0') ?? 0,
      telat: int.tryParse(json['telat']?.toString() ?? '0') ?? 0,
    );
  }
}
