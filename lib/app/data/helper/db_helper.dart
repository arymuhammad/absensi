import 'dart:async';

import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/data/model/cabang_model.dart';
import 'package:absensi/app/data/model/login_offline_model.dart';
import 'package:absensi/app/data/model/server_api_model.dart';
import 'package:absensi/app/data/model/shift_kerja_model.dart';
import 'package:absensi/app/modules/absen/views/absen_view_backup.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/visit_model.dart';
import 'custom_dialog.dart';
import 'db_result.dart';

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
    String dbPath = await getDatabasesPath();
    String path = '$dbPath/$_databaseName';
    // print('db location : ' + dbPath);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("""CREATE TABLE IF NOT EXISTS tbl_user(
        id TEXT PRIMARY KEY NOT NULL,
        nama TEXT,
        username TEXT,
        password TEXT,
        kode_cabang TEXT,
        nama_cabang TEXT,
        nik TEXT,
        lat TEXT,
        long TEXT,
        foto TEXT,
        no_telp TEXT,
        level TEXT,
        level_user TEXT,
        area_coverage TEXT,
        visit TEXT,
        cek_stok TEXT,
        id_region TEXT,
        leave_balance TEXT,
        created_at TEXT,
        parent_id TEXT,
        nama_parent TEXT
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
        area_coverage INTEGER,
        area_coverage_qr INTEGER
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
        is_rnd TEXT DEFAULT '0',
        status_sync TEXT DEFAULT 'PENDING',

        UNIQUE (id_user, tgl_visit, visit_in)
      )
      """);
    await db.execute("""CREATE TABLE IF NOT EXISTS absen(
        tanggal_masuk DATE NOT NULL,
        tanggal_pulang DATE,
        id_user TEXT NOT NULL,
        kode_cabang TEXT,
        nama TEXT,
        id_shift TEXT,
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
        device_info2 TEXT DEFAULT '',
        status_sync TEXT DEFAULT 'PENDING',
        
        PRIMARY KEY (tanggal_masuk, id_user)
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

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final result = await db.rawQuery("PRAGMA table_info(absen)");
      final isExist = result.any((col) => col['name'] == 'status_sync');

      if (!isExist) {
        await db.execute(
          "ALTER TABLE absen ADD COLUMN status_sync TEXT DEFAULT 'PENDING'",
        );
      }

      final result2 = await db.rawQuery("PRAGMA table_info(tbl_visit_area)");
      final isExist2 = result2.any((col) => col['name'] == 'status_sync');

      if (!isExist2) {
        await db.execute(
          "ALTER TABLE tbl_visit_area ADD COLUMN status_sync TEXT DEFAULT 'PENDING'",
        );
      }
    }
    // 🔥 VERSI 4 → ubah PRIMARY KEY (WAJIB recreate table)
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE absen RENAME TO absen_old");

      await db.execute("""
      CREATE TABLE absen(
        tanggal_masuk DATE NOT NULL,
        tanggal_pulang DATE,
        id_user TEXT NOT NULL,
        kode_cabang TEXT,
        nama TEXT,
        id_shift TEXT,
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
        device_info2 TEXT DEFAULT '',
        status_sync TEXT DEFAULT 'PENDING',
        PRIMARY KEY (tanggal_masuk, id_user)
      )
    """);

      await db.execute("""
      INSERT OR IGNORE INTO absen SELECT * FROM absen_old
    """);

      await db.execute("DROP TABLE absen_old");
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE tbl_visit_area RENAME TO tbl_visit_area_old",
      );

      await db.execute("""
    CREATE TABLE tbl_visit_area(
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
      is_rnd TEXT DEFAULT '0',
      status_sync TEXT DEFAULT 'PENDING',
      UNIQUE (id_user, tgl_visit, visit_in)
    )
  """);

      await db.execute("""
    INSERT INTO tbl_visit_area
    SELECT * FROM tbl_visit_area_old
  """);

      await db.execute("DROP TABLE tbl_visit_area_old");
    }
  }

  Future<List<LoginOffline>> loginUserOffline(
    String username,
    String password,
  ) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
      "select * from tbl_user where username='$username' and password='$password'",
    );
    return res.map((e) => LoginOffline.fromJson(e)).toList();
  }

  Future<DbResult> insertDataAbsen(Absen todo) async {
    try {
      Database db = await instance.database;
      // validasi
      if (todo.idShift == "0" || todo.idShift == "" || todo.idShift == null) {
        return DbResult(success: false, message: "Invalid shift");
      }

      final result = await db.insert(
        'absen',
        todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      if (result == 0) {
        return DbResult(success: false, message: "Duplicate data");
      }

      return DbResult(success: true, message: "Success");
    } on TimeoutException catch (e) {
      return DbResult(success: false, message: "Timeout: ${e.toString()}");
    } catch (e) {
      return DbResult(success: false, message: e.toString());
    }
  }

  Future<List<Absen>> getPendingAbsen() async {
    final db = await instance.database;
    final result = await db.query(
      'absen',
      where: 'status_sync != ?',
      whereArgs: ['SUCCESS'],
    );

    return result.map((e) => Absen.fromJson(e)).toList();
  }

  Future<void> updateStatusAbsen(
    String id,
    String tglMasuk,
    String status,
  ) async {
    final db = await instance.database;
    await db.update(
      'absen',
      {"status_sync": status},
      where: 'id_user = ? and tanggal_masuk=?',
      whereArgs: [id, tglMasuk],
    );
  }

  Future<List<Visit>> getPendingVisit() async {
    final db = await instance.database;
    // print("DB PATH APP: ${db.path}");
    final result = await db.query(
      'tbl_visit_area',
      where: 'status_sync IS NULL OR status_sync != ?',
      whereArgs: ['SUCCESS'],
    );

    return result.map((e) => Visit.fromJson(e)).toList();
  }

  Future<void> updateStatusVisit(
    String id,
    String tglVisit,
    String branch,
    String status,
  ) async {
    final db = await instance.database;
    // final result = 
    await db.update(
      'tbl_visit_area',
      {"status_sync": status},
      where: 'id_user = ? and tgl_visit=? and visit_in=?',
      whereArgs: [id, tglVisit, branch],
    );
    // print('UPDATE RESULT: $result');
  }

  Future<DbResult> updateDataAbsen(
    Map<String, dynamic> todo,
    String idUser,
    String tglMasuk,
  ) async {
    try {
      // validasi jika data kosong
      if (todo.isEmpty) {
        return DbResult(success: false, message: "No data update");
      }

      Database db = await instance.database;
      // loadingDialog("Sedang mengirim data...", "");
      final result = await db
          .update(
            'absen',
            todo,
            where: 'id_user = ? AND tanggal_masuk = ?',
            whereArgs: [idUser, tglMasuk],
          )
          .timeout(const Duration(minutes: 2));
      // 🔥 cek apakah ada row yang ke-update
      if (result == 0) {
        return DbResult(
          success: false,
          message: "Data not found / No row affected",
        );
      }

      return DbResult(success: true, message: "Update succeed");
    } on TimeoutException {
      return DbResult(
        success: false,
        message: "Timeout while updating database",
      );
    } catch (e) {
      return DbResult(success: false, message: e.toString());
    }
  }

  Future<void> deleteDataAbsenMasuk(String idUser, String tglMasuk) async {
    Database db = await instance.database;
    await db.delete(
      'absen',
      where: 'id_user = ? and tanggal_masuk = ?',
      whereArgs: [idUser, tglMasuk],
    );
    // return res;
  }

  Future<void> deleteDataAbsenPulang(
    Map<String, dynamic> todo,
    String idUser,
    String tglMasuk,
  ) async {
    Database db = await instance.database;
    await db.update(
      'absen',
      todo,
      where: 'id_user = ? and tanggal_masuk = ?',
      whereArgs: [idUser, tglMasuk],
    );
    // return res;
  }

  Future<void> deleteDataVisitMasuk(
    String idUser,
    String tglMasuk,
    String visitIn,
  ) async {
    Database db = await instance.database;
    await db.delete(
      'tbl_visit_area',
      where: 'id_user = ? and tgl_visit = ? and visit_in = ?',
      whereArgs: [idUser, tglMasuk, visitIn],
    );
    // return res;
  }

  Future<void> deleteDataVisitPulang(
    Map<String, dynamic> todo,
    String idUser,
    String tglMasuk,
  ) async {
    Database db = await instance.database;
    await db.update(
      'tbl_visit_area',
      todo,
      where: 'id_user = ? and tgl_visit = ?',
      whereArgs: [idUser, tglMasuk],
    );
    // return res;
  }

  Future<void> insertShift(ShiftKerja todo) async {
    Database db = await instance.database;
    await db.insert('shift_kerja', todo.toJson());
    // return res;
  }

  Future<List<ShiftKerja>> getShift() async {
    Database db = await instance.database;
    var res = await db.query('shift_kerja');
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
    var res = await db.query('tbl_cabang');
    return res.map((e) => Cabang.fromJson(e)).toList();
  }

  Future<List<Absen>> getAbsenToday(String idUser, String today) async {
    Database db = await instance.database;
    var res = await db.query(
      'absen',
      where: 'id_user=? and tanggal_masuk = ?',
      whereArgs: [idUser, today],
    );
    return res.map((e) => Absen.fromJson(e)).toList();
  }

  Future<List<Absen>> getAllAbsenToday(String today) async {
    Database db = await instance.database;
    var res = await db.query(
      'absen',
      where: 'tanggal_masuk = ?',
      whereArgs: [today],
      orderBy: 'tanggal_masuk DESC',
    );
    return res.map((e) => Absen.fromJson(e)).toList();
  }

  Future<List<Absen>> getLimitDataAbsen(
    String idUser,
    String date1,
    String date2,
  ) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
      " SELECT A.*, B.nama_shift, C.nama_cabang FROM absen A INNER JOIN shift_kerja B ON B.id = A.id_shift INNER JOIN tbl_cabang C ON C.kode_cabang = A.kode_cabang WHERE id_user =  '$idUser'  AND tanggal_masuk BETWEEN '$date1' AND '$date2' ORDER BY tanggal_masuk DESC LIMIT 7 ",
    );
    return res.map((json) => Absen.fromJson(json)).toList();
  }

  Future<DbResult> insertDataVisit(Visit todo) async {
    try {
      Database db = await instance.database;
      final result = await db
          .insert(
            'tbl_visit_area',
            todo.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          )
          .timeout(const Duration(minutes: 2));
      // 🔥 kalau result == 0 → insert di-ignore (duplicate)
      if (result == 0) {
        return DbResult(
          success: false,
          message: "Duplicate data / already exists",
        );
      }

      return DbResult(success: true, message: "Insert success");
    } on TimeoutException {
      return DbResult(success: false, message: "Timeout while inserting data");
    } catch (e) {
      return DbResult(success: false, message: e.toString());
    }
    // return res;
  }

  Future<DbResult> updateDataVisit(
    Map<String, dynamic> todo,
    String idUser,
    String tglVisit,
    String visitIn,
  ) async {
    try {
      // validasi jika data kosong
      if (todo.isEmpty) {
        return DbResult(success: false, message: "No data update");
      }

      Database db = await instance.database;
      final result = await db
          .update(
            'tbl_visit_area',
            todo,
            where: 'id_user=? and tgl_visit=? and visit_in=?',
            whereArgs: [idUser, tglVisit, visitIn],
          )
          .timeout(const Duration(minutes: 2));
      // 🔥 cek apakah ada row yang ke-update
      if (result == 0) {
        return DbResult(
          success: false,
          message: "Data not found / No row affected",
        );
      }
      return DbResult(success: true, message: "Update succeed");
    } on TimeoutException {
      return DbResult(
        success: false,
        message: "Timeout while updating database",
      );
    } catch (e) {
      return DbResult(success: false, message: e.toString());
    }
  }

  Future<List<Visit>> getVisitToday(
    String idUser,
    String date,
    String cabang,
    int limit,
  ) async {
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
      " SELECT A.*, B.nama_cabang FROM tbl_visit_area A LEFT JOIN tbl_cabang B ON B.kode_cabang = A.visit_in WHERE id_user =  '$idUser'  AND tgl_visit ='$date' $cbg ORDER BY tgl_visit DESC, jam_in DESC $lmt",
    );
    return res.map((e) => Visit.fromJson(e)).toList();
  }

  Future<List<Visit>> getLimitDataVisit(
    String idUser,
    String date1,
    String date2,
  ) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
      " SELECT A.*, B.nama_cabang FROM tbl_visit_area A LEFT JOIN tbl_cabang B ON B.kode_cabang = A.visit_in WHERE id_user =  '$idUser'  AND tgl_visit BETWEEN '$date1' AND '$date2' ORDER BY tgl_visit DESC, jam_in DESC LIMIT 7 ",
    );
    return res.map((json) => Visit.fromJson(json)).toList();
  }

  Future<void> insertDataUser(LoginOffline todo) async {
    Database db = await instance.database;
    await db.insert('tbl_user', todo.toJson());
    // return res;
  }

  Future<void> updateDataUser(
    Map<String, dynamic> todo,
    String idUser,
    String username,
  ) async {
    Database db = await instance.database;
    await db.update(
      'tbl_user',
      todo,
      where: 'id=? and username=?',
      whereArgs: [idUser, username],
    );
    // return res;
  }

  Future<List<LoginOffline>> getDataUser(String idUser) async {
    Database db = await database;
    var res = await db.query('tbl_user', where: 'id = ?', whereArgs: [idUser]);
    return res.map((e) => LoginOffline.fromJson(e)).toList();
  }

  Future<List<Absen>> getAllDataAbsen(
    String id,
    String tgl1,
    String tgl2,
  ) async {
    Database db = await instance.database;
    var res = await db.rawQuery(
      '''
  SELECT A.*, B.nama_shift, C.nama_cabang
  FROM absen A
  LEFT JOIN shift_kerja B ON B.id = A.id_shift
  LEFT JOIN tbl_cabang C ON C.kode_cabang = A.kode_cabang
  WHERE A.id_user = ? 
    AND A.tanggal_masuk BETWEEN ? AND ?
  ORDER BY A.tanggal_masuk DESC
''',
      [id, tgl1, tgl2],
    );
    return res.map((json) => Absen.fromJson(json)).toList();
  }

  Future<List<Visit>> getAllDataVisit(
    String id,
    String tgl1,
    String tgl2,
  ) async {
    Database db = await instance.database;
    var res = await db.query(
      'tbl_visit_area',
      where: ' id_user =? AND tgl_visit BETWEEN ? AND ?',
      whereArgs: [id, tgl1, tgl2],
      orderBy: "tgl_visit DESC, jam_in DESC",
    );
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

  // Future<void> updateFaceData(Map<String, dynamic> data, String id) async {
  //   try {
  //     Database db = await instance.database;
  //     await db
  //         .update('tbl_user', data, where: 'id=?', whereArgs: [id])
  //         .timeout(const Duration(minutes: 3))
  //         .then((value) {
  //           return showToast('Data wajah tersimpan di local storage');
  //         });
  //   } on TimeoutException catch (e) {
  //     return showToast(e.toString());
  //   } catch (e) {
  //     return showToast(e.toString());
  //   }
  // }

  // Future<List> getFaceData(String id) async {
  //   Database db = await database;
  //   var res = await db.query('tbl_user', columns: ["data_wajah"], where: 'id=?', whereArgs: [id]);
  //   return res.map((e) => e).toList();
  // }
  Future<List<String>> getAllPhotoPaths({required bool isVisit}) async {
    final db = await database;

    final abs = await db.rawQuery('''
    SELECT foto_masuk, foto_pulang FROM absen
  ''');
    final vst = await db.rawQuery('''
    SELECT foto_in, foto_out FROM tbl_visit_area
  ''');

    List<String> paths = [];
    if (isVisit) {
      for (var row in vst) {
        if (row['foto_in'] != null && row['foto_in'] != '') {
          paths.add(row['foto_in'] as String);
        }
        if (row['foto_out'] != null && row['foto_out'] != '') {
          paths.add(row['foto_out'] as String);
        }
      }
    } else {
      for (var row in abs) {
        if (row['foto_masuk'] != null && row['foto_masuk'] != '') {
          paths.add(row['foto_masuk'] as String);
        }
        if (row['foto_pulang'] != null && row['foto_pulang'] != '') {
          paths.add(row['foto_pulang'] as String);
        }
      }
    }

    return paths;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null; // 🔥 WAJIB
    }
  }
}
