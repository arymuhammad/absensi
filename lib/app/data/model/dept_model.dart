class Dept {
  late String id;
  late String nama;
  late String visit;

  Dept({required this.id, required this.nama, required this.visit});
  Dept.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    visit = json['visit'];
  }
}
