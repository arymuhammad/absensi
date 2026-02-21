String shiftName({required String jamMasuk}) {
  final time = jamMasuk.substring(0, 5); // ambil HH:mm
  switch (time) {
    case '09:00':
      return '(Pagi/Early)';
    case '12:00':
      return '(Middle)';
    case '13:00':
      return '(Middle II)';
    case '14:00':
      return '(Siang/Late)';
    case '15:00':
      return '(Late Delivery)';
    default:
      return '(Custom)';
  }
}
