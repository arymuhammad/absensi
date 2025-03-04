class DataWajah {
  String? id;
  String? nama;
  String? dataWajah;

  DataWajah({this.id, this.nama, this.dataWajah});
  DataWajah.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    dataWajah = json['data_wajah']??'';
  }
}
