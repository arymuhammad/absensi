class ReportSales {
  String? cabang;
  String? brandCabang;
  String? tanggal;
  String? sales;
  String? salesAmount;
  
  ReportSales({this.cabang, this.brandCabang, this.tanggal, this.sales, this.salesAmount});
  ReportSales.fromJson(Map<String, dynamic> json) {
    cabang = json['Cabang'];
    brandCabang = json['brand_cabang'];
    tanggal = json['Tanggal'];
    sales = json['SALES'];
    salesAmount = json['SALES_AMOUNT'];
  }
}
