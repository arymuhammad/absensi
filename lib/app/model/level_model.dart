class Level {
  String? id;
  String? namaLevel;

  Level({this.id, this.namaLevel});

  Level.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaLevel = json['nama'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama'] = namaLevel;
    return data;
  }
}