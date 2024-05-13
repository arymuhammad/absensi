
import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/data/model/cabang_model.dart';
import 'package:absensi/app/data/model/login_offline_model.dart';
import 'package:absensi/app/data/model/shift_kerja_model.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/visit_model.dart';

class SQLHelper {
  final _databaseName = "/absensi.db";
  SQLHelper._privateConstructor();
   static final SQLHelper instance = SQLHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    // Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = await getDatabasesPath() + _databaseName;
    // print('db location : ' + dbPath);
    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("""CREATE TABLE IF NOT EXISTS tbl_user(
        id TEXT PRIMARY KEY NOT NULL,
        nama TEXT,
        username TEXT,
        password TEXT,
        kode_cabang TEXT,
        nama_cabang TEXT,
        lat TEXT,
        long TEXT,
        foto TEXT,
        no_telp TEXT,
        level TEXT,
        level_user TEXT,
        area_coverage TEXT,
        visit TEXT,
        cek_stok TEXT
      )
      """);
    await db.execute("""CREATE TABLE IF NOT EXISTS tbl_cabang(
        id INTEGER PRIMARY KEY NOT NULL,
        kode_cabang TEXT,
        nama_cabang TEXT,
        brand_cabang TEXT,
        lat TEXT,
        long TEXT,
        aktif INTEGER,
        jenis_store TEXT,
        jenis_cabang TEXT,
        area_coverage INTEGER
      )
      """);
    await db.execute("""CREATE TABLE IF NOT EXISTS shift_kerja(
        id INTEGER PRIMARY KEY NOT NULL,
        nama_shift TEXT,
        jam_masuk TEXT,
        jam_pulang TEXT
      )
      """);
    await db.execute("""CREATE TABLE IF NOT EXISTS tbl_level_user(
        id INTEGER PRIMARY KEY NOT NULL,
        nama TEXT,
        visit TEXT,
        cek_stok TEXT
      )
      """);
    await db.execute("""CREATE TABLE IF NOT EXISTS tbl_visit_area(
        id_user TEXT,
        nama TEXT,
        tgl_visit DATE,
        visit_in TEXT,
        jam_in TEXT,
        visit_out TEXT,
        jam_out TEXT,
        foto_in TEXT,
        lat_in TEXT,
        long_in TEXT,
        foto_out TEXT,
        lat_out TEXT,
        long_out TEXT,
        device_info TEXT,
        device_info2 TEXT,
        is_rnd TEXT DEFAULT '0'
      )
      """);
    await db.execute("""CREATE TABLE IF NOT EXISTS absen(
        tanggal_masuk DATE PRIMARY KEY NOT NULL,
        tanggal_pulang DATE,
        id_user TEXT,
        kode_cabang TEXT,
        nama TEXT,
        id_shift INTEGER,
        jam_masuk TEXT,
        jam_pulang TEXT DEFAULT '',
        jam_absen_masuk TEXT,
        jam_absen_pulang TEXT DEFAULT '',
        foto_masuk TEXT,
        foto_pulang TEXT DEFAULT '',
        lat_masuk TEXT,
        long_masuk TEXT,
        lat_pulang TEXT DEFAULT '',
        long_pulang TEXT DEFAULT '',
        device_info TEXT,
        device_info2 TEXT DEFAULT ''
      )
      """);

  }
  
  Future<List<LoginOffline>> loginUserOffline(
      String username, String password) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
        "select * from tbl_user where username='$username' and password='$password'");
    return res.map((e) => LoginOffline.fromJson(e)).toList();
  }

  Future<int> insertDataAbsen(Absen todo) async {
    Database db = await instance.database;
    var res = await db.insert('absen', todo.toJson());
    return res;
  }

  Future<int> updateDataAbsen(
      Map<String, dynamic> todo, String idUser, String tglMasuk) async {
    Database db = await instance.database;
    var res = await db.update('absen', todo,
        where: 'id_user = ? and tanggal_masuk = ?',
        whereArgs: [idUser, tglMasuk]);
    return res;
  }

  Future<int> insertShift(ShiftKerja todo) async {
    Database db = await instance.database;
    var res = await db.insert('shift_kerja', todo.toJson());
    return res;
  }

  Future<List<ShiftKerja>> getShift() async {
    Database db = await instance.database;
    var res = await db.query(
      'shift_kerja',
    );
    return res.map((e) => ShiftKerja.fromJson(e)).toList();
  }

  Future truncateShift()async{
    Database db = await instance.database;
    var res = await db.delete('shift_kerja');
    return res;
  }

  Future<int> insertCabang(Cabang todo) async {
    Database db = await instance.database;
    var res = await db.insert('tbl_cabang', todo.toJson());
    return res;
  }

  Future<List<Cabang>> getCabang() async {
    Database db = await instance.database;
    var res = await db.query(
      'tbl_cabang',
    );
    return res.map((e) => Cabang.fromJson(e)).toList();
  }

  Future truncateCabang()async{
    Database db = await instance.database;
    var res = await db.delete('tbl_cabang');
    return res;
  }

  Future<List<Absen>> getAbsenToday(String idUser, String today) async {
    Database db = await instance.database;
    var res = await db.query('absen',
        where: 'id_user=? and tanggal_masuk = ?', whereArgs: [idUser, today]);
    return res.map((e) => Absen.fromJson(e)).toList();
  }

  Future<List<Absen>> getAllAbsenToday(String today) async {
    Database db = await instance.database;
    var res = await db.query('absen',
        where: 'tanggal_masuk = ?', whereArgs: [today]);
    return res.map((e) => Absen.fromJson(e)).toList();
  }

  Future<List<Absen>> getLimitDataAbsen(
      String idUser, String date1, String date2) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
        " SELECT A.*, B.nama_shift FROM absen A INNER JOIN shift_kerja B ON B.id = A.id_shift WHERE id_user =  '$idUser'  AND tanggal_masuk BETWEEN '$date1' AND '$date2' ORDER BY tanggal_masuk DESC LIMIT 7 ");
    return res.map((json) => Absen.fromJson(json)).toList();
  }

  Future<int> insertDataVisit(Visit todo) async {
    Database db = await instance.database;
    var res = await db.insert('tbl_visit_area', todo.toJson());
    return res;
  }

  Future<int> updateDataVisit(
      Map<String, dynamic> todo, String idUser, String tglVisit, String visitIn) async {
    Database db = await instance.database;
    var res = await db.update('tbl_visit_area', todo,
        where: 'id_user=? and tgl_visit=? and visit_in=?', whereArgs: [idUser, tglVisit, visitIn]);
    return res;
  }

  Future<List<Visit>> getVisitToday( String idUser, String date, String cabang, int limit) async {
    var lmt = "";
    var cbg = "";
    if(limit > 0){
      lmt = "LIMIT $limit";
    }else{
      lmt = "";
    }
    if(cabang !=""){
      cbg = " AND A.visit_in = '$cabang'";
    }else{
      cbg = "";
    }
    Database db = await instance.database;
    var res = await db.rawQuery(" SELECT A.*, B.nama_cabang FROM tbl_visit_area A LEFT JOIN tbl_cabang B ON B.kode_cabang = A.visit_in WHERE id_user =  '$idUser'  AND tgl_visit ='$date' $cbg ORDER BY tgl_visit, jam_in DESC $lmt");
    return res.map((e) => Visit.fromJson(e)).toList();
  }

  Future<List<Visit>> getLimitDataVisit(
      String idUser, String date1, String date2) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
        " SELECT A.*, B.nama_cabang FROM tbl_visit_area A LEFT JOIN tbl_cabang B ON B.kode_cabang = A.visit_in WHERE id_user =  '$idUser'  AND tgl_visit BETWEEN '$date1' AND '$date2' ORDER BY tgl_visit DESC LIMIT 7 ");
    return res.map((json) => Visit.fromJson(json)).toList();
  }


  Future<int> insertDataUser(LoginOffline todo) async {
    Database db = await instance.database;
    var res = await db.insert('tbl_user', todo.toJson());
    return res;
  }
  

  Future<int> updateDataUser(
      Map<String, dynamic> todo, String idUser, String username) async {
    Database db = await instance.database;
    var res = await db.update('tbl_user', todo,
        where: 'id=? and username=?', whereArgs: [idUser, username]);
    return res;
  }


  Future<List<LoginOffline>> getDataUser(String idUser) async {
    Database db = await database;
    var res = await db.query('tbl_user', where: 'id = ?', whereArgs: [idUser]);
    return res.map((e) => LoginOffline.fromJson(e)).toList();
  }

  Future<List<Absen>> getAllDataAbsen(idUser) async {
    Database db = await instance.database;
    var res = await db.query('absen',
        orderBy: "tanggal_masuk DESC", where: 'id_user=$idUser');

    return res.map((json) => Absen.fromJson(json)).toList();
  }


  Future close() async => _database!.close();

}