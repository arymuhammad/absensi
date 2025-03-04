import 'dart:async';

import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/data/model/cabang_model.dart';
import 'package:absensi/app/data/model/login_offline_model.dart';
import 'package:absensi/app/data/model/server_api_model.dart';
import 'package:absensi/app/data/model/shift_kerja_model.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/visit_model.dart';
import 'custom_dialog.dart';

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

  Future<Database> _initDatabase() async {
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
        data_wajah BLOB,
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
    await db.execute("""CREATE TABLE IF NOT EXISTS server(
        id TEXT,
        server_name TEXT,
        base_url TEXT,
        path TEXT,
        status TEXT
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

  Future<void> insertDataAbsen(Absen todo) async {
    try {
      Database db = await instance.database;
      // await db.insert('absen', todo.toJson());
      //loadingDialog("Sedang mengirim data...", ""); //dipindah kembali ke form_absen.dart
      await db
          .insert('absen', todo.toJson())
          .timeout(const Duration(minutes: 3))
          .then((value) {
        // Get.back();
        return showToast('Data saved on local storage');
        // return succesDialog(Get.context, "Y",
        //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
      });
    } on TimeoutException catch (e) {
      return showToast(e.toString());
    } catch (e) {
      return showToast(e.toString());
      // return failedDialog(Get.context, 'ERROR', e.toString());
    }
  }

  Future<void> updateDataAbsen(
      Map<String, dynamic> todo, String idUser, String tglMasuk) async {
    try {
      Database db = await instance.database;
      // loadingDialog("Sedang mengirim data...", "");
      await db
          .update('absen', todo,
              where: 'id_user = ? and tanggal_masuk = ?',
              whereArgs: [idUser, tglMasuk])
          .timeout(const Duration(minutes: 3))
          .then((value) {
            return showToast('Data is successfully updated on local storage');
            // Get.back();
            // return succesDialog(Get.context, "Y",
            //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
          });
    } on TimeoutException catch (e) {
      return showToast(e.toString());
    } catch (e) {
      return showToast(e.toString());
      // return failedDialog(Get.context, 'ERROR', e.toString());
    }
    // return res;
  }

  Future<void> deleteDataAbsenMasuk(String idUser, String tglMasuk) async {
    Database db = await instance.database;
    await db.delete('absen',
        where: 'id_user = ? and tanggal_masuk = ?',
        whereArgs: [idUser, tglMasuk]);
    // return res;
  }

  Future<void> deleteDataAbsenPulang(
      Map<String, dynamic> todo, String idUser, String tglMasuk) async {
    Database db = await instance.database;
    await db.update('absen', todo,
        where: 'id_user = ? and tanggal_masuk = ?',
        whereArgs: [idUser, tglMasuk]);
    // return res;
  }

  Future<void> deleteDataVisitMasuk(
      String idUser, String tglMasuk, String visitIn) async {
    Database db = await instance.database;
    await db.delete('tbl_visit_area',
        where: 'id_user = ? and tgl_visit = ? and visit_in = ?',
        whereArgs: [idUser, tglMasuk, visitIn]);
    // return res;
  }

  Future<void> deleteDataVisitPulang(
      Map<String, dynamic> todo, String idUser, String tglMasuk) async {
    Database db = await instance.database;
    await db.update('tbl_visit_area', todo,
        where: 'id_user = ? and tgl_visit = ?', whereArgs: [idUser, tglMasuk]);
    // return res;
  }

  Future<void> insertShift(ShiftKerja todo) async {
    Database db = await instance.database;
    await db.insert('shift_kerja', todo.toJson());
    // return res;
  }

  Future<List<ShiftKerja>> getShift() async {
    Database db = await instance.database;
    var res = await db.query(
      'shift_kerja',
    );
    return res.map((e) => ShiftKerja.fromJson(e)).toList();
  }

  Future truncateUser() async {
    try {
      Database db = await instance.database;
      await db.delete('tbl_user');
      return showToast('Data berhasil dihapus');
    } on Exception catch (e) {
      showToast(e.toString());
    }
  }

  Future truncateAbsen() async {
    Database db = await instance.database;
    var res = await db.delete('absen');
    return res;
  }

  Future truncateVisit() async {
    Database db = await instance.database;
    var res = await db.delete('tbl_visit_area');
    return res;
  }

  Future truncateShift() async {
    Database db = await instance.database;
    var res = await db.delete('shift_kerja');
    return res;
  }

  Future truncateLevel() async {
    Database db = await instance.database;
    var res = await db.delete('tbl_level_user');
    return res;
  }

  Future truncateCabang() async {
    Database db = await instance.database;
    var res = await db.delete('tbl_cabang');
    return res;
  }

  Future truncateServer() async {
    Database db = await instance.database;
    var res = await db.delete('server');
    return res;
  }

  Future<void> insertCabang(Cabang todo) async {
    Database db = await instance.database;
    await db.insert('tbl_cabang', todo.toJson());
    // return res;
  }

  Future<List<Cabang>> getCabang() async {
    Database db = await instance.database;
    var res = await db.query(
      'tbl_cabang',
    );
    return res.map((e) => Cabang.fromJson(e)).toList();
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
        where: 'tanggal_masuk = ?',
        whereArgs: [today],
        orderBy: 'tanggal_masuk DESC');
    return res.map((e) => Absen.fromJson(e)).toList();
  }

  Future<List<Absen>> getLimitDataAbsen(
      String idUser, String date1, String date2) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
        " SELECT A.*, B.nama_shift FROM absen A INNER JOIN shift_kerja B ON B.id = A.id_shift WHERE id_user =  '$idUser'  AND tanggal_masuk BETWEEN '$date1' AND '$date2' ORDER BY tanggal_masuk DESC LIMIT 7 ");
    return res.map((json) => Absen.fromJson(json)).toList();
  }

  Future<void> insertDataVisit(Visit todo) async {
    try {
      Database db = await instance.database;
      await db
          .insert('tbl_visit_area', todo.toJson())
          .timeout(const Duration(minutes: 3))
          .then((value) {
        // Get.back();
        return showToast('Data saved on local storage');
        // return succesDialog(Get.context, "Y",
        //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
      });
    } on TimeoutException catch (e) {
      return showToast(e.toString());
    } catch (e) {
      return showToast(e.toString());
      // return failedDialog(Get.context, 'ERROR', e.toString());
    }
    // return res;
  }

  Future<void> updateDataVisit(Map<String, dynamic> todo, String idUser,
      String tglVisit, String visitIn) async {
    try {
      Database db = await instance.database;
      await db
          .update('tbl_visit_area', todo,
              where: 'id_user=? and tgl_visit=? and visit_in=?',
              whereArgs: [idUser, tglVisit, visitIn])
          .timeout(const Duration(minutes: 3))
          .then((value) {
            // Get.back();
            return showToast('Data is successfully updated on local storage');
            // return succesDialog(Get.context, "Y",
            //     "Harap tidak menutup aplikasi selama proses syncron data absensi");
          });
    } on TimeoutException catch (e) {
      return showToast(e.toString());
    } catch (e) {
      return showToast(e.toString());
      // return failedDialog(Get.context, 'ERROR', e.toString());
    }
    // return res;
  }

  Future<List<Visit>> getVisitToday(
      String idUser, String date, String cabang, int limit) async {
    var lmt = "";
    var cbg = "";
    if (limit > 0) {
      lmt = "LIMIT $limit";
    } else {
      lmt = "";
    }
    if (cabang != "") {
      cbg = " AND A.visit_in = '$cabang'";
    } else {
      cbg = "";
    }
    Database db = await instance.database;
    var res = await db.rawQuery(
        " SELECT A.*, B.nama_cabang FROM tbl_visit_area A LEFT JOIN tbl_cabang B ON B.kode_cabang = A.visit_in WHERE id_user =  '$idUser'  AND tgl_visit ='$date' $cbg ORDER BY tgl_visit DESC, jam_in DESC $lmt");
    return res.map((e) => Visit.fromJson(e)).toList();
  }

  Future<List<Visit>> getLimitDataVisit(
      String idUser, String date1, String date2) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
        " SELECT A.*, B.nama_cabang FROM tbl_visit_area A LEFT JOIN tbl_cabang B ON B.kode_cabang = A.visit_in WHERE id_user =  '$idUser'  AND tgl_visit BETWEEN '$date1' AND '$date2' ORDER BY tgl_visit DESC, jam_in DESC LIMIT 7 ");
    return res.map((json) => Visit.fromJson(json)).toList();
  }

  Future<void> insertDataUser(LoginOffline todo) async {
    Database db = await instance.database;
    await db.insert('tbl_user', todo.toJson());
    // return res;
  }

  Future<void> updateDataUser(
      Map<String, dynamic> todo, String idUser, String username) async {
    Database db = await instance.database;
    await db.update('tbl_user', todo,
        where: 'id=? and username=?', whereArgs: [idUser, username]);
    // return res;
  }

  Future<List<LoginOffline>> getDataUser(String idUser) async {
    Database db = await database;
    var res = await db.query('tbl_user', where: 'id = ?', whereArgs: [idUser]);
    return res.map((e) => LoginOffline.fromJson(e)).toList();
  }

  Future<List<Absen>> getAllDataAbsen() async {
    Database db = await instance.database;
    var res = await db.query('absen', orderBy: "tanggal_masuk DESC");
    return res.map((json) => Absen.fromJson(json)).toList();
  }

  Future<List<Visit>> getAllDataVisit() async {
    Database db = await instance.database;
    var res = await db.query('tbl_visit_area',
        orderBy: "tgl_visit DESC, jam_in DESC");
    return res.map((json) => Visit.fromJson(json)).toList();
  }

  Future<void> insertServer(ServerApi todo) async {
    Database db = await instance.database;
    await db.insert('server', todo.toJson());
    // return res;
  }

  Future<void> updateServer(Map<String, dynamic> todo, String id) async {
    Database db = await instance.database;
    await db.update('server', todo, where: 'id=?', whereArgs: [id]);
    // return res;
  }

  Future<List<ServerApi>> getServer() async {
    Database db = await database;
    var res = await db.query('server');
    return res.map((e) => ServerApi.fromJson(e)).toList();
  }

  Future<void> updateFaceData(Map<String, dynamic> data, String id) async {
    try {
      Database db = await instance.database;
      await db
          .update('tbl_user', data, where: 'id=?', whereArgs: [id])
          .timeout(const Duration(minutes: 3))
          .then((value) {
            return showToast('Data wajah tersimpan di local storage');
          });
    } on TimeoutException catch (e) {
      return showToast(e.toString());
    } catch (e) {
      return showToast(e.toString());
    }
  }

  Future<List> getFaceData(String id) async {
    Database db = await database;
    var res = await db.query('tbl_user', columns: ["data_wajah"], where: 'id=?', whereArgs: [id]);
    return res.map((e) => e).toList();
  }

  Future close() async => _database!.close();
}
