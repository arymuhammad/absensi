class FotoProfil {
  late String? foto;

  FotoProfil({this.foto});
  FotoProfil.fromJson(Map<String, dynamic> json) {
    foto = json['foto'];
  }
}
