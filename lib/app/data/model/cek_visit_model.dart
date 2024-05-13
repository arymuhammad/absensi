class CekVisit {
  late String total;
  late String tglVisit;
  late String kodeStore;
  late String namaStore;
  String? isRnd;


  CekVisit(
      {required this.total, required this.tglVisit, required this.kodeStore, required this.namaStore, this.isRnd});

  CekVisit.fromJson(Map<String, dynamic> json) {
    total = json["total"] !=null?json["total"]:"";
    tglVisit = json["tgl_visit"] !=null?json["tgl_visit"]:"";
    kodeStore = json["visit_in"] !=null?json["visit_in"]:"";
    namaStore = json["nama_cabang"] !=null?json["nama_cabang"]:"";
    isRnd = json["is_rnd"];
  }
}
