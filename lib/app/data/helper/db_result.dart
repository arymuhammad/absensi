class DbResult {
  final bool success;
  final String message;

  DbResult({required this.success, required this.message});

   factory DbResult.success([String msg = "Success"]) =>
      DbResult(success: true, message: msg);

  factory DbResult.error(String msg) =>
      DbResult(success: false, message: msg);
}