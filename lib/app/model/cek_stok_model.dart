class CekStok {
  String? kodeBarang;
  String? namaBarang;
  String? departemen;
  String? kelompok;
  String? subKelompok;
  String? merk;
  String? warna;
  String? ukuran;
  String? sisa;

  CekStok(
      {this.kodeBarang,
      this.namaBarang,
      this.departemen,
      this.kelompok,
      this.subKelompok,
      this.merk,
      this.warna,
      this.ukuran,
      this.sisa});

  CekStok.fromJson(Map<String, dynamic> json) {
    kodeBarang = json['Kode_Barang'];
    namaBarang = json['nama_barang'];
    departemen = json['Departemen'];
    kelompok = json['Kelompok'];
    subKelompok = json['SubKelompok'];
    merk = json['Merk'];
    warna = json['Warna'];
    ukuran = json['Ukuran'];
    sisa = json['SISA'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Kode_Barang'] = kodeBarang;
    data['Nama_Barang'] = namaBarang;
    data['Departemen'] = departemen;
    data['Kelompok'] = kelompok;
    data['SubKelompok'] = subKelompok;
    data['Merk'] = merk;
    data['Warna'] = warna;
    data['Ukuran'] = ukuran;
    data['SISA'] = sisa;
    return data;
  }
}