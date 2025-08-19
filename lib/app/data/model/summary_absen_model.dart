class SummaryAbsenModel {
  late int? hadir;
  late int? tepatWaktu;
  late int? telat;

  SummaryAbsenModel({this.hadir, this.tepatWaktu, this.telat});

  SummaryAbsenModel.fromJson(Map<String, dynamic> json) {
    hadir = json['hadir'] ?? 0;
    tepatWaktu = json['tepat_waktu'] ?? 0;
    telat = json['telat'] ?? 0;
  }
}
