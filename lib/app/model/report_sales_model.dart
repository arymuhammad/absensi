class ReportSales {
  String? cabang;
  String? brandCabang;
  String? alias;
  String? tanggal;
  String? sales;
  String? salesAmount;

  ReportSales(
      {this.cabang,
      this.brandCabang,
      this.alias,
      this.tanggal,
      this.sales,
      this.salesAmount});
  ReportSales.fromJson(Map<String, dynamic> json) {
    cabang = json['Cabang'];
    brandCabang = json['brand_cabang'];
    alias = json['Alias'];
    tanggal = json['Tanggal'];
    sales = json['SALES'];
    salesAmount = json['SALES_AMOUNT'];
  }
}
